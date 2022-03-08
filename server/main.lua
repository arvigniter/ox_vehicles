local resource = 'ox_vehicles'

MySQL.ready(function()
	local vehicles = MySQL:selectVehicles()

	for i = 1, #vehicles do
		local veh = vehicles[i]
		vehicle.new(veh.charid, json.decode(veh.data), veh.x, veh.y, veh.z, veh.heading)
	end
end)

AddEventHandler('onResourceStop', function(res)
	if res == resource then
		local parameters = {}
		local size = 0

		for _, veh in pairs(vehicle.list) do
			if veh.owner then
				size += 1
				local coords = GetEntityCoords(veh.entity)
				parameters[size] = { coords.x, coords.y, coords.z, GetEntityHeading(veh.entity), veh.plate }
			end
			DeleteEntity(veh.entity)
		end

		if size > 0 then
			MySQL:saveVehicles(parameters)
		end
	else
		local parameters = {}
		local size = 0

		for _, veh in pairs(vehicle.list) do
			if veh.script == res then
				if veh.owner then
					size += 1
					local coords = GetEntityCoords(veh.entity)
					parameters[size] = { coords.x, coords.y, coords.z, GetEntityHeading(veh.entity), veh.plate }
				end

				veh:despawn()
			end
		end

		if size > 0 then
			MySQL:saveVehicles(parameters)
		end
	end
end)

local function deleteVehicle(entity)
	local plate = GetVehicleNumberPlateText(entity)
	local veh = vehicle(plate)

	if veh then
		veh:store()
	else
		DeleteEntity(entity)
	end
end

lib.addCommand('group.admin', 'car', function(source, args)
	local ped = GetPlayerPed(source)
	local entity = GetVehiclePedIsIn(ped)

	if entity then
		local veh = vehicle(NetworkGetNetworkIdFromEntity(entity))

		if veh then
			veh:remove()
		else
			deleteVehicle(entity)
		end
	end

	if args.owner then
		args.owner = Player(args.owner)
		if not args.owner then return end
	end

	local coords = GetEntityCoords(ped)
	local veh = vehicle.new(args.owner?.charid or false, {new = args.owner, model = joaat(args.model)}, coords.x, coords.y, coords.z, GetEntityHeading(ped))

	local timeout = 50
	repeat
		Wait(0)
		timeout -= 1
		SetPedIntoVehicle(ped, veh.entity, -1)
	until GetVehiclePedIsIn(ped, false) == veh.entity or timeout < 1
end, {'model:string', 'owner:?number'})

lib.addCommand('group.admin', 'dv', function(source)
	local ped = GetPlayerPed(source)
	local entity = GetVehiclePedIsIn(ped)

	if entity then
		local obj = vehicle(NetworkGetNetworkIdFromEntity(entity))

		if obj then
			obj:remove()
		else
			deleteVehicle(entity)
		end
	end
end)
