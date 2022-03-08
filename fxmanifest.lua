--[[ FX Information ]]--
fx_version   'cerulean'
use_fxv2_oal 'yes'
lua54        'yes'
game         'gta5'

--[[ Resource Information ]]--
name         'ox_vehicles'
author       'Overextended'
version      '0.0.1'
repository   'https://github.com/overextended/ox_vehicles'
description  'Vehicle management system for ox_core'

--[[ Manifest ]]--
server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'@ox_lib/init.lua',
	'@ox_core/imports.lua',
	'server/mysql.lua',
    'server/vehicle.lua',
	'server/main.lua',
}
