--准备esx
ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
-- ESX = exports["es_extended"]:getSharedObject()
print("garage loading")
--客户端向服务端请求玩家职业信息

--把东西都放在function和thread或者event里面，不然会报错
--因为你插件加载的时候依赖的东西还没有加载完，所以会报错
--在服务端准备ESX
local job = nil
local ped = GetPlayerPed(-1);
local playerindex = NetworkGetPlayerIndexFromPed(ped)
local serverid = GetPlayerServerId(playerindex)
local menu = nil
local crood = nil

--呼叫载具部分
local show = true
local garagezone = nil
local isinzone = false


local function isingarage(garagezone)
    Citizen.CreateThread(function ()
        ped = GetPlayerPed(-1);
        while true do
            Citizen.Wait(1000)
            --侦测玩家是否在区域内
            crood = GetEntityCoords(ped)
            -- print(crood.x)
            -- print(ped)
            isinzone = garagezone:isPointInside(crood)    
            -- print(isinzone)    
            --玩家在机库区域内可以存和取，要把提示分开
            --玩家在飞机中提示储存飞机，玩家不在飞机内提示取出飞机
            if isinzone and show and IsPedInAnyPlane(ped) then
                ESX.ShowHelpNotification("您在公司机库区域内，可以按~INPUT_SAVE_REPLAY_CLIP~（有些人可能是~INPUT_SELECT_CHARACTER_TREVOR~）储存飞机")
                show = false
            elseif (isinzone and show and not IsPedInAnyPlane(ped))  then
                ESX.ShowHelpNotification("您在公司机库区域内，可以按~INPUT_SELECT_CHARACTER_FRANKLIN~打开菜单(键位都可以自己改)")
                show = false
            end
            if not isinzone then
                show = true
            end
            -- print(isinzone)
        end
    end)
    
end

local function createzone()
    Citizen.Wait(1000)
    --当在区域内时，才能使用命令调出载具仓库菜单，调用polyzone插件创建区域
    --首先在数据库中读取本公司机库区域坐标，向服务端请求，带有客户端服务器id
    -- print(job)
    TriggerServerEvent('aircraft_company_garage:queryzone',job,serverid)
    --接受服务端返回的机库区域坐标，并保存
    RegisterNetEvent('aircraft_company_garage:queryzone')
    local zone = nil
    AddEventHandler('aircraft_company_garage:queryzone', function (zone)
        zone = zone
        -- print(json.encode(zone))
        --使用polyzone插件创建区域,数据库取数据需要时间，所以在此处创建
        --如果在外面创建，数据库的数据还没传回来，zone就是nil，会报错
        Citizen.Wait(1000)
        garagezone = PolyZone:Create({
            vector2(zone.x1, zone.y1),
            vector2(zone.x2, zone.y2),
            vector2(zone.x3, zone.y3),
            vector2(zone.x4, zone.y4)
        }, {
            name="garagezone",
            minZ=-5.0,
            maxZ=62.0,
            debugGrid=false,
            gridDivisions=25
        })
        -- print("zone created")
        -- print(json.encode(garagezone))
        isingarage(garagezone)
        menu = MenuV:CreateMenu("公司载具仓库", "按退格键关闭", 'bottomright',255,0,0,'size-125','default', 'menuv', 'aircraft_company_garage')
    end)
   
end


Citizen.CreateThread(function()
    while true do
        if ESX.IsPlayerLoaded() then
                -- print("checkjob15")
            Citizen.Wait(5000)
            -- print("checkjob18")
            RegisterNetEvent('aircraft_company_garage:checkjob')
            -- print("checkjob20")
            TriggerServerEvent('aircraft_company_garage:checkjob',serverid)
            -- print("checkjob22")
            --接受服务端返回的职业信息并保存
            AddEventHandler('aircraft_company_garage:checkjob', function (job1)
                job = job1--此处job代表航空公司名称
                -- print("job" .. job)
                -- print("checkjob")
                createzone()
            end)
            -- print("checkjob29")
            break
        end
        Citizen.Wait(1000)
    end

end)



local open = false

--一个函数用于生成载具

local function spawnvehicle(model,plate)
    -- print(model)
    -- print(plate)
    -- print("spawnvehicle function")
    local crood = GetEntityCoords(ped)
    local gameplate = nil
    ESX.Game.SpawnVehicle(model, crood, 0.0, function(vehicle)
        TaskWarpPedIntoVehicle(ped, vehicle, -1)
        SetVehicleNumberPlateText(vehicle, plate)
        gameplate = GetVehicleNumberPlateText(vehicle)
        --将这辆载具的游戏内车牌号写入数据库，以便载具准备入库时，能够找到这辆载具
        TriggerServerEvent("aircraft_company_garage:writeplate",plate,gameplate)
    end)
    
end

local haveloadedmenu = false
local function spawnvehicle1(model,plate)
    
    TriggerServerEvent("aircraft_company_garage:changestatus",plate,serverid,model)
    --接受服务端传回的数据库更改结果，如成功则生成载具
    
end
RegisterNetEvent("aircraft_company_garage:changestatus")
AddEventHandler("aircraft_company_garage:changestatus", function(result,model,plate)
    if result then
        --客户端生成载具
        local crood = GetEntityCoords(ped)
        menu:ClearItems(true)
        -- print("spawnvehicle event")
        spawnvehicle(model,plate)
        --客户端生成载具后，删除菜单，下次打开时重新生成
        open = false
        menu:Close()
        MenuV:CloseMenu(menu)
        --重置菜单
        menu:ClearItems(true)
        haveloadedmenu = false
        --提示玩家按退格键关闭菜单
        ESX.ShowHelpNotification("您可以按~INPUT_FRONTEND_RRIGHT~关闭菜单")
    else
        ESX.ShowHelpNotification("数据库载具状态更改失败，请联系滑稽")
    end
    
end)

local buttons = {}
--event只能注册一次,重复注册的话会重复执行
--注册event要放在全局作用域，不能放在函数里面

local function openmenu()
    
    -- print("openmenu")
    --向服务端请求查询数据库中的载具信息，这件事只能在服务端完成
    TriggerServerEvent("aircraft_company_garage:queryvehicle",job,serverid)
    --接受服务端传回的载具信息,并保存
   
    
end
RegisterNetEvent("aircraft_company_garage:receivevehicle")
local vehicles = nil
AddEventHandler("aircraft_company_garage:receivevehicle", function(result)
    --将载具信息写入菜单
    vehicles = result
    -- print(json.encode(vehicles))
    --创建一个数组，用于存储按钮，后面触发按钮按下的事件时，需要用到
    menu:ClearItems(true)
    buttons = {}
    for i, v in ipairs(vehicles) do
        -- print(v.state)
        -- print(v.plate)
        -- print(v.model)
        -- print("------------------")
        if v.state == true then
            buttons[i]=menu:AddButton({icon ='✈️',label = v.plate .. v.model, })
            --选择时触发事件，生成载具
            -- print(i)
            -- print(buttons[i])
            buttons[i]:On("select", function()
                -- print("select")
                --向服务端请求载具
                spawnvehicle1(v.model,v.plate)
            end)                
        else
            --添加载具信息,如果被取出，则显示为灰色
            buttons[i]=menu:AddButton({icon ='🚫',label = v.plate .. v.model,disabled = true })
        end
        haveloadedmenu = true
        menu:Open()
        buttons = {}

    end
    --提示玩家按退格键关闭菜单
    ESX.ShowHelpNotification("您可以按~INPUT_FRONTEND_RRIGHT~关闭菜单,按一次关不上就多按几次")
    

end)

--使用命令调出载具仓库菜单,检查条件
RegisterCommand("open_aircraft_company_garage_menu", function()
    if isinzone then
        if job then
            open  = true
            openmenu()
            -- print("prepareopenmenu")
        else
            ESX.ShowHelpNotification("你不是航空公司员工")
        end        
    else
        ESX.ShowHelpNotification("你不在航空公司机库区域内")
    end
end, false)

--为命令添加按键
RegisterKeyMapping("open_aircraft_company_garage_menu", "打开航空公司机库菜单", "keyboard", "F6")

--储存载具部分

--若玩家在载具内，则储存载具,检查玩家驾驶的载具是否是公司的载具
local function storevehicle()
    --从数据库中查询玩家驾驶的载具的游戏内车牌号
    local vehicle = GetVehiclePedIsIn(ped)
    local gameplate = GetVehicleNumberPlateText(vehicle)
    
    TriggerServerEvent("aircraft_company_garage:checkplate",gameplate,serverid,vehicle)
    
end
--接收服务端返回的结果，如果是公司的载具，则储存载具
RegisterNetEvent("aircraft_company_garage:checkplate")
AddEventHandler("aircraft_company_garage:checkplate", function(result,gameplate,vehicle)
    if result then
        --在服务端数据库中将载具状态改为1
        TriggerServerEvent("aircraft_company_garage:storevehicle",gameplate,serverid,vehicle)
        --接收服务端返回的结果，如果成功，则删除载具
        
    else
        ESX.ShowHelpNotification("这不是公司的载具")
    end
end)
RegisterNetEvent("aircraft_company_garage:storevehicle")
AddEventHandler("aircraft_company_garage:storevehicle", function(result1,vehicle)
    if result1 then
        --使用ESX删除载具
        ESX.Game.DeleteVehicle(vehicle)
        --提示玩家储存成功
        ESX.ShowHelpNotification("载具入库成功")
    else
        ESX.ShowHelpNotification("载具入库失败，请联系滑稽")
    end
end)



--注册命令，按下按键时储存载具
RegisterCommand("cs", function()
    --检查玩家是否在机库区域内
    if isinzone then
    storevehicle()
    else
        ESX.ShowHelpNotification("你不在航空公司机库区域内")
    end
end, false)

--为命令添加按键
RegisterKeyMapping("cs", "储存载具", "keyboard", "F3")

