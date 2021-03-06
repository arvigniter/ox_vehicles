local Query = {
	DELETE_VEHICLE = 'DELETE FROM user_vehicles WHERE plate = ?',
	STORE_VEHICLE = 'UPDATE user_vehicles SET stored = ? WHERE plate = ?',
	VEHICLE_EXISTS = 'SELECT 1 FROM user_vehicles WHERE plate = ?',
	SELECT_VEHICLES = 'SELECT charid, data, x, y, z, heading FROM user_vehicles WHERE stored = "false"',
	UPDATE_VEHICLES = 'UPDATE user_vehicles SET x = ?, y = ?, z = ?, heading = ? WHERE plate = ?',
	INSERT_VEHICLE = 'INSERT INTO user_vehicles (plate, charid, type, x, y, z, heading, data) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
}

function MySQL:deleteVehicle(plate)
	self.update(Query.DELETE_VEHICLE, { plate })
end

function MySQL:storeVehicle(state, plate)
	self.update(Query.STORE_VEHICLE, { state or 'impound', plate })
end

function MySQL:vehicleExists(plate)
	return self.scalar.await(Query.VEHICLE_EXISTS, { plate })
end

function MySQL:insertVehicle(plate, owner, type, x, y, z, heading, data)
	self.prepare(Query.INSERT_VEHICLE, { plate, owner, type, x or 0.0, y or 0.0, z or 0.0, heading or 0.0, data })
end

function MySQL:saveVehicles(parameters)
	self.prepare(Query.UPDATE_VEHICLES, parameters)
end

function MySQL:selectVehicles()
	return self.query.await(Query.SELECT_VEHICLES)
end
