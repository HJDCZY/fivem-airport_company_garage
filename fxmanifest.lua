fx_version 'bodacious'
game "gta5"

name 'aircraft_company_garage'
author 'HJDCZY'
description 'limited garage'
version'1.0.0'

--fxmanifest.lua在服务器打开时加载，重启插件服务端不会重新读取
--所以如果更改fxmanifest.lua，需要重启服务器,而不是仅仅重启插件

client_scripts{
	'@menuv/menuv.lua',
    '@es_extended/locale.lua',
	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/EntityZone.lua',
	'@PolyZone/CircleZone.lua',
	'@PolyZone/ComboZone.lua',
    'client.lua',
    -- 'example.lua',
}

ui_page 'index.html'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	-- '@PolyZone/client.lua',
	'@es_extended/locale.lua',
	'server.lua',
	-- 'config.lua',
	
}

files{
   'script.js',
   'style.css',
   'log.txt',
}
-- 依赖于es_extended和mysql-async