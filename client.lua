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
local menu = MenuV:CreateMenu("公司载具仓库", "按退格键关闭", 'bottomright',255,0,0,'size-100','default', 'menuv', 'aircraft_company_garage')
local crood = nil

--呼叫载具部分
local show = true
local garagezone = nil
local isinzone = false
local hasqueryaplane = false

Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(100);
        if ESX.IsPlayerLoaded() then
            --触发命令，加载机库
            ExecuteCommand("loadgarage")
            return;
        end 
    end
end)

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
        if zone == nil then
            ESX.ShowNotification("您所在的公司没有机库")
            return;
        end
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
        -- 在四个点的中心画blip
        local blip = AddBlipForCoord((zone.x1+zone.x2+zone.x3+zone.x4)/4,(zone.y1+zone.y2+zone.y3+zone.y4)/4,10)
        SetBlipSprite(blip, 359)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 1.0)
        SetBlipColour(blip, 0)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(zone.label)
        EndTextCommandSetBlipName(blip)
        -- print("zone created")
        -- print(json.encode(garagezone))
        isingarage(garagezone)
        
    end)
end

RegisterCommand("loadgarage",function ()
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
end,false)



local open = false
local vehicleout = nil
--一个函数用于生成载具

local function monitorvehiclehealth(plate)
    --监测被取出载具的健康状态，如果低于一半，就提示玩家并且写入log
    Citizen.CreateThread(function()
        print("monitorvehiclehealth")
        while true do
            Citizen.Wait(100)
            if vehicleout ~= nil then
                local enginehealth = GetVehicleEngineHealth(vehicleout)
                local bodyhealth = GetVehicleBodyHealth(vehicleout)
                if enginehealth < 500 then
                    ESX.ShowNotification("您取出的载具引擎健康状态不佳，请及时修理")
                    --发送给服务端，写入log
                    TriggerServerEvent("aircraft_company_garage:damagelog",serverid,plate,"engine")                   
                    break
                end
                if bodyhealth < 500 then
                    ESX.ShowNotification("您取出的载具车身健康状态不佳，请及时修理")
                    --发送给服务端，写入log
                    TriggerServerEvent("aircraft_company_garage:damagelog",serverid,plate,"body")
                    break
                end
            end
        end
    end)
end


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
        vehicleout = vehicle;
        monitorvehiclehealth(plate)
        return true
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
        local i =1
        while i<=50 do
            menu:Close()
            MenuV:CloseMenu(menu)
            i = i+1
        end
        --重置菜单
        menu:ClearItems(true)
        haveloadedmenu = false
        --提示玩家按退格键关闭菜单
        ESX.ShowHelpNotification("您可以按~INPUT_FRONTEND_RRIGHT~关闭菜单")
        
        --让玩家无法再次打开菜单
        hasqueryaplane = true
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
    if result == false then
        ESX.ShowHelpNotification("有其他玩家正在操作机库，请稍后再试")
        return
    end
    if hasqueryaplane == true then
        ESX.ShowHelpNotification("您已经取出了一架飞机，无法再次取出")
        return
    end
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
            buttons[i]=menu:AddButton({icon ='✈️',label = v.plate .. v.label, })
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
            buttons[i]=menu:AddButton({icon ='🚫',label = v.plate .. v.label,disabled = true })
        end
        haveloadedmenu = true
        menu:Open()
        buttons = {}
        --为了防止玩家打开菜单之后退出游戏，导致其他玩家无法使用机库
        --打开菜单后，服务端计时30秒，30秒后，如果玩家没有关闭菜单，则自动关闭
        TriggerServerEvent("aircraft_company_garage:opentime",serverid)

    end
    --提示玩家按退格键关闭菜单
    ESX.ShowHelpNotification("您可以按~INPUT_FRONTEND_RRIGHT~关闭菜单,按一次关不上就多按几次")
    Citizen.CreateThread(function ()
        while true do
            Citizen.Wait(0)
            if IsControlJustPressed(0,  202) then
                local u =1
                while u<=50 do
                    menu:Close()
                    MenuV:CloseMenu(menu)
                    u = u+1
                end
                open = false
                haveloadedmenu = false
                menu:ClearItems(true)
                break
            end
        end
        print("closemenu")
        TriggerServerEvent("aircraft_company_garage:closemenu",serverid)
        return
    end)
end)

--接受服务端发送的计时结果，如果玩家没有关闭菜单，则自动关闭
RegisterNetEvent("aircraft_company_garage:forceclosemenu")
AddEventHandler("aircraft_company_garage:forceclosemenu", function()
    if haveloadedmenu then
        local u =1
        while u<=50 do
            menu:Close()
            MenuV:CloseMenu(menu)
            u = u+1
        end
        open = false
        haveloadedmenu = false
        menu:ClearItems(true)
        ESX.ShowHelpNotification("您打开了菜单但是30秒内没有关闭，已经为您关闭")
        TriggerServerEvent("aircraft_company_garage:closemenu",serverid)
    end
end)

-- menu:On("close", function()
--     --提示服务器玩家已经关闭菜单
--     TriggerServerEvent("aircraft_company_garage:closemenu",serverid)
-- end)

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
        hasqueryaplane = false
        vehicleout = nil
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

--添加一个marker，玩家进入的时候可以加入飞行学院
local marker = {
    x = -1059.0,
    y = -3441.0,
    z = 13.0,
    radius = 2.0,
}
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        --画出marker
        DrawMarker(1,marker.x,marker.y,marker.z,0,0,0,0,0,0,marker.radius,marker.radius,marker.radius,255,200,200,200,0,0,0,0)
        local ped = PlayerPedId()
        local crood = GetEntityCoords(ped)
        local distance = GetDistanceBetweenCoords(crood.x,crood.y,crood.z,marker.x,marker.y,marker.z,true)
        if distance < marker.radius+1 then
            ESX.ShowHelpNotification("按~INPUT_CONTEXT~加入飞行学院")
            if IsControlJustReleased(0, 38) then
                --在服务端设置玩家职业为飞行学院学生
                TriggerServerEvent("aircraft_company_garage:setjob",serverid)
            end
        end
    end
end)

--接收服务端返回的结果，如果玩家已经有职业，则提示玩家
RegisterNetEvent("aircraft_company_garage:setjob")
AddEventHandler("aircraft_company_garage:setjob", function(result)
    print(result)   
    if not result then
        TriggerEvent("chat:addMessage", {
            color = {255,255,255},
            multiline = true,
            args = {"你已经有职业了"}
        })
    else
        TriggerEvent("chat:addMessage", {
            color = {255,255,255},
            multiline = true,
            args = {"你已经加入飞行学院"}
        })
    end
end)