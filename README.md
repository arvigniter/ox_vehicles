# ox_vehicles
Vehicle management and persistence, designed for use with ox_core.  
Still a work in progress and contains some test code (i.e. saveProperties event).

## Requirements
- [oxmysql](https://github.com/overextended/oxmysql)
- [ox_core](https://github.com/overextended/ox_core)
- [ox_lib](https://github.com/overextended/ox_lib)

## Database
Utilises foreign keys to link the vehicle owner (charid) to the characters table.  
Execute the following query.
```sql
CREATE TABLE IF NOT EXISTS `vehicles` (
  `plate` char(8) NOT NULL DEFAULT '',
  `charid` int(11) NOT NULL,
  `type` varchar(10) NOT NULL DEFAULT 'automobile',
  `x` float DEFAULT NULL,
  `y` float DEFAULT NULL,
  `z` float DEFAULT NULL,
  `heading` float DEFAULT NULL,
  `data` longtext NOT NULL,
  `trunk` longtext DEFAULT NULL,
  `glovebox` longtext DEFAULT NULL,
  `stored` varchar(50) NOT NULL DEFAULT 'false',
  PRIMARY KEY (`plate`),
  KEY `FK__characters` (`charid`) USING BTREE,
  CONSTRAINT `FK__characters` FOREIGN KEY (`charid`) REFERENCES `characters` (`charid`) ON DELETE CASCADE
) ENGINE=InnoDB;
```

## Usage
```lua
---@param netid number Network id for the vehicle entity
---@return table CVehicle
---Returns an instance of CVehicle.
---Provided by ox_core/imports
local vehicle = Vehicle(netid)

---@param owner number charid or false
---@param model string | number
---@param coords vector x, y, z, w
---@param data table
---@return table CVehicle
---Creates an instance of CVehicle. Loads existing vehicle data from the database, or generates new data.
---Provided by ox_core/imports
local vehicle = Ox.CreateVehicle(owner, model, coords, data)

---Deletes the entity.
vehicle:despawn()

---Deletes the entity and removes it from the database.
vehicle:delete()

---@param state string
---Deletes the entity and sets its stored state in the database (i.e. impound, garageA, garabeB)
vehicle:store(state)
```

## Example
```lua
local vehicles = {}

CreateThread(function()
	vehicles[1] = Ox.CreateVehicle(false, `sultanrs`, vec(-56.479122, -1116.870362, 26.432250, 0.000030517578))
	vehicles[2] = Ox.CreateVehicle(false, `sultanrs`, vec(-50.742858, -1116.514282, 26.432250, 0.000030517578))

	print(json.encode(vehicles, {indent=true}))

	for k, veh in pairs(vehicles) do
		veh:despawn()
	end
end)
```
