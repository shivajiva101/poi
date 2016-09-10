poi = {}
poi.places = {}

-- Save & load functions
local function save_data()
	if poi.places == nil then
		return
	end
	print("[poi] Saving data")
	local file = io.open(minetest.get_worldpath().."/poi.txt", "w")
	if file then
		file:write(minetest.serialize(poi.places))
		file:close()
	end
end

local function load_data()
	local file = io.open(minetest.get_worldpath().."/poi.txt", "r")
	if file then
		local table = minetest.deserialize(file:read("*all"))
		if type(table) == "table" then
			poi.places = table
			return
		end
	end
end

-- load data from file
load_data()

minetest.register_chatcommand("poi_add", {
	params = "<name>",
	description = "Adds a POI to the list",
	privs = {server=true},
	
	func = function(name, param)
		
		if param == "" then
			return false, "Invalid usage, see /help poi_add."
		end
		
		-- return if name already in use
		if poi.places[param] then
		    return false, param.." is already assigned in the POI list"
		end
		
		-- get player position and store using name as key
		local player = minetest.get_player_by_name(name)
		local pos = nil
			if player then
				pos = player:getpos()
				poi.places[param] = {x=pos.x, y=pos.y, z=pos.z}
				save_data()
				return false, param.." added at "..minetest.pos_to_string(pos)
			else
				return false, "Unable to get position."
			end
	end,
})

minetest.register_chatcommand("poi_remove", {
	params = "<name>",
	description = "Removes a Point Of Interest from the list",
	privs = {server=true},
	
	func = function(name, param)
		
		if param == "" then
			return false, "Invalid usage, see /help poi_remove."
		end

		-- remove entry
		if poi.places[param] then
		    poi.places[param] = nil
		    -- save arena to file
		    save_data()
		    return false, param.." POI removed!"
		else
		  -- return if name doesn't exist
		  return false, param.." doesn't exist!"
		  
		end		
	end,
})

minetest.register_chatcommand("poi", {
	params = "<name>", 
	description = "Lists or teleports you to Points Of Interest",
	privs = {interact=true},
	
	func = function(name, param)
		if param == "" then
		  local poiStrings = {}
		  for key, value in pairs(poi.places) do
		    table.insert(poiStrings, key)
		  end
		  if #poiStrings == 0 then
		    return true, "No Points Of Interest set!"
		  end
		  return true, table.concat(poiStrings, "\n")
		else
		  if poi.places[param] then
		    local pos = {x=poi.places[param].x, y=poi.places[param].y, z=poi.places[param].z}
		    minetest.get_player_by_name(name):setpos(pos) -- move player to new position
		  else
		    return true, param.." doesn't exist!"
		  end
		end		    
	end,
})
