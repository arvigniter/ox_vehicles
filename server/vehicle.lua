local vehicle = {
	list = {}
}

setmetatable(vehicle, {
	__add = function(self, veh)
		self.list[veh.netid] = veh
	end,

	__sub = function(self, veh)
		self.list[veh.netid] = nil
	end,

	__call = function(self, netid)
		return self.list[netid]
	end
})

local CVehicle = {}
CVehicle.__index = CVehicle
CVehicle.__newindex = CVehicle

function CVehicle:despawn()
	DeleteEntity(self.entity)
	return vehicle - self
end

function CVehicle:delete()
	if self.owner then MySQL:deleteVehicle(self.plate) end
	DeleteEntity(self.entity)
	return vehicle - self
end

function CVehicle:store(state)
	if self.owner then MySQL:storeVehicle(state, self.plate) end
	DeleteEntity(self.entity)
	return vehicle - self
end

local function generatePlate()
	local str = {}

	for i = 1, 2 do
		str[i] = string.char(math.random(48, 57))
	end

	for i = 3, 6 do
		str[i] = string.char(math.random(65, 90))
	end

	for i = 7, 8 do
		str[i] = string.char(math.random(48, 57))
	end

	return table.concat(str)
end

---@param charid number
---@param data table
---@param vehicleType string
---@param x number
---@param y number
---@param z number
---@param heading number
---@param plate string
---@return table data
---Generates a suitable license plate and inserts a vehicle into the database.
local function generateVehicleData(charid, data, vehicleType, x, y, z, heading, plate)
	data.new = nil

	if not plate or MySQL:vehicleExists(plate) then
		repeat
			plate = generatePlate()
		until not MySQL:vehicleExists(plate)

		data.plate = plate
	end

	MySQL:insertVehicle(plate, charid, vehicleType, x, y, z, heading, json.encode(data))
	return data
end

---@param charid number
---@param data table
---@param x number
---@param y number
---@param z number
---@param heading number
---@return table vehicle
---Creates an instance of CVehicle. Loads existing vehicle data from the database, or generates new data.
function vehicle.new(charid, data, x, y, z, heading)
	if type(data.model) == 'string' then
		data.model = joaat(data.model)
	end

	local script = GetInvokingResource()
	local entity

	if x and y and z then
		entity = Citizen.InvokeNative(`CREATE_AUTOMOBILE`, data.model, x, y, z, heading or 90.0)
		Wait(100)
	end

	if entity then
		local vehicleType = GetVehicleType(entity)
		if not vehicleType then return end

		if charid and data.new then
			data = generateVehicleData(charid, data, vehicleType, x, y, z, heading or 90.0, data.plate)
		elseif not data.plate then
			data.plate = generatePlate()
		end

		if x and y and z then
			local self = setmetatable({
				owner = charid,
				data = data,
				plate = data.plate,
				entity = entity,
				netid = NetworkGetNetworkIdFromEntity(entity),
				script = script
			}, CVehicle)

			Entity(entity).state.owner = charid
			local entityOwner = NetworkGetEntityOwner(entity)

			if entityOwner < 1 then
				CreateThread(function()
					while true do
						Wait(5000)
						if not DoesEntityExist(entity) then return end

						entityOwner = NetworkGetEntityOwner(entity)

						if entityOwner > 0 then
							return TriggerClientEvent('ox_lib:setVehicleProperties', entityOwner, self.netid, data)
						end
					end
				end)
			else
				TriggerClientEvent('ox_lib:setVehicleProperties', entityOwner, self.netid, data)
			end

			SetVehicleNumberPlateText(entity, data.plate)
			return self, vehicle + self
		end
	end
end

for name, method in pairs(CVehicle) do
	exports(name, method)
end

exports('new', vehicle.new)

exports('get', function(netid)
	return vehicle.list[netid]
end)

exports('list', function()
	return vehicle.list
end)

_ENV.vehicle = vehicle

RegisterNetEvent('saveProperties', function(data)
	MySQL.query('UPDATE vehicles SET data = ? WHERE plate = ?', { json.encode(data), data.plate })
end)
