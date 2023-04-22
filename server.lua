ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)--准备esx
-- ESX = exports["es_extended"]:getSharedObject()
--服务端准备mysql-async
-- Mysql.ready(function ()
-- print("garage loading")
-- end)
local job = nil
--查询玩家职业，返回给客户端
RegisterNetEvent('aircraft_company_garage:checkjob')
AddEventHandler('aircraft_company_garage:checkjob', function (serverid)
    -- print("checkjob13")
    --在ex_extended中查询玩家职业
    local xPlayer = ESX.GetPlayerFromId(source)
    -- print("checkjob16")

    xPlayer = ESX.GetPlayerFromId(source)
    -- print("getxplayer")

    if xPlayer~=nil then
        -- print(xPlayer)
        local jobcache = xPlayer.getJob()
        -- print("checkjob19")
       -- print(jobcache)
        job = jobcache.name
        -- print(job)  
        --返回给客户端
        TriggerClientEvent('aircraft_company_garage:checkjob',serverid,job)
    end

end)--查询职业的事情只能在服务端完成

--查询机库区域坐标，返回给客户端
RegisterNetEvent('aircraft_company_garage:queryzone')
AddEventHandler('aircraft_company_garage:queryzone', function (job, serverid)
    local job = job
    --查询数据库中的机库区域坐标
    -- print(job)
    local result = {}
    MySQL.Async.fetchAll("SELECT * FROM `aircraft_company` WHERE `company` = @company", {--注意数据库表名
        ['@company'] = job
    },function (rest)
        --返回的是对象数组，读取第一项
        -- print(json.encode(rest))
        TriggerClientEvent('aircraft_company_garage:queryzone',serverid,rest[1])
    end)
end)

local menuinuse = false
--接受客户端的载具仓库菜单请求，查询数据库中的载具信息
RegisterNetEvent("aircraft_company_garage:queryvehicle")
AddEventHandler("aircraft_company_garage:queryvehicle", function(job,serverid)
    local job = job
    --查询数据库中的载具信息
    -- print("before query")
    --如果有其他玩家在使用菜单，那么不予查询
    if menuinuse then
        TriggerClientEvent("aircraft_company_garage:receivevehicle",serverid,false)
    else
            MySQL.Async.fetchAll("SELECT * FROM `aircraft_company_garage` WHERE `company` = @company", {--注意数据库表名
            ['@company'] = job
                },function(rest)
            -- print(json.encode(rest))
            -- print("queryvehicle")
            menuinuse = true
            TriggerClientEvent("aircraft_company_garage:receivevehicle",serverid,rest)
        end)   
    end
       
    --只能有一位玩家使用菜单，所以在打开菜单时，变量为0，不允许其他玩家使用菜单    
end)

--客户端玩家非正常关闭菜单时，释放其他玩家的使用权
RegisterNetEvent("aircraft_company_garage:closemenu")
AddEventHandler("aircraft_company_garage:closemenu", function(serverid)
    menuinuse = false
end)

--客户端生成载具后，服务端在数据库中更改载具状态
RegisterNetEvent("aircraft_company_garage:changestatus")
AddEventHandler("aircraft_company_garage:changestatus", function(plate,serverid,model)--status为0表示其他玩家不可使用，有玩家正在使用
    local job = job
    -- print(plate)
    --在数据库中更改载具状态
    MySQL.Async.execute("UPDATE `aircraft_company_garage` SET `state` = @state WHERE `plate` = @plate", {
        ['@state'] = 0,
        ['@plate'] = plate
    },function()
        TriggerClientEvent("aircraft_company_garage:changestatus",serverid,true,model,plate)
        
        -- print("changestatus")
    end
    )
    --向客户端返回更改结果
    
end)

--客户端生成载具后，服务端写入游戏内车牌号作为载具的唯一标识
RegisterNetEvent("aircraft_company_garage:writeplate")
AddEventHandler("aircraft_company_garage:writeplate", function(plate,gameplate)
    -- print(plate)
    -- print(gameplate)
    --在数据库中更改载具状态
    MySQL.Async.execute("UPDATE `aircraft_company_garage` SET `gameplate` = @gameplate WHERE `plate` = @plate", {
        ['@plate'] = plate,
        ['@gameplate'] = gameplate
    },function()
        -- print("writeplate")
        menuinuse = false
    end
    )
    
end)

--客户端要求储存载具，服务端检查载具是否是公司的
RegisterNetEvent("aircraft_company_garage:checkplate")
AddEventHandler("aircraft_company_garage:checkplate", function(gameplate,serverid,vehicle)
    -- print(plate)
    --在数据库中获取所有载具信息
    MySQL.Async.fetchAll("SELECT * FROM `aircraft_company_garage` WHERE `gameplate` = @gameplate", {
        ['@gameplate'] = gameplate
    },function(rest)
        --判断有没有取出数据,如果没有取出数据，说明载具不是公司的
        -- print(json.encode(rest))
        -- print(rest[1])
        if rest[1] == nil then
            TriggerClientEvent("aircraft_company_garage:checkplate",serverid,false,gameplate,vehicle)
        else
            TriggerClientEvent("aircraft_company_garage:checkplate",serverid,true,gameplate,vehicle)
        end
    end
    )
    
end)

--储存载具，在数据库中更改载具状态
RegisterNetEvent("aircraft_company_garage:storevehicle")
AddEventHandler("aircraft_company_garage:storevehicle", function(gameplate,serverid,vehicle)
    -- print(plate)
    --在数据库中更改载具状态
    MySQL.Async.execute("UPDATE `aircraft_company_garage` SET `state` = @state WHERE `gameplate` = @gameplate", {
        ['@state'] = 1,
        ['@gameplate'] = gameplate
    },function()
        TriggerClientEvent("aircraft_company_garage:storevehicle",serverid,true,vehicle)
    end
    )
    
end)

--在服务端设置玩家职业为飞行学院学生
RegisterNetEvent("aircraft_company_garage:setjob")
AddEventHandler("aircraft_company_garage:setjob", function(serverid)
    local xPlayer = ESX.GetPlayerFromId(source)
    --检查玩家是否为无业，如果是无业，设置玩家职业为飞行学院学生
    if xPlayer.getJob().name == "unemployed" then
        xPlayer.setJob("flightschool", 0)
        TriggerClientEvent("aircraft_company_garage:setjob",serverid,true)
    else
        TriggerClientEvent("aircraft_company_garage:setjob",serverid,false)
    end
    
    -- xPlayer.setJob("flightschool", 0)
end)

