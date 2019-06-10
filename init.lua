poi = {}
poi.places = {}
poi.places.poi = {}
poi.places.shops = {}

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

-- initialise missing entries
if not poi.places.poi then poi.places.poi = {} end
if not poi.places.shops then poi.places.shops = {} end

--register shops
for k, v in pairs(poi.places.shops) do
  minetest.register_chatcommand(k, {
      params = "",
      description = "Teleport to ".. k .." shop",

      func = function(name, param)
        local pos = v
        local text = 'Welcome to '
        ..k..'! Click the shop and hit the stack under the item'
        ..' you wish to buy. Have a nice day!'
        minetest.get_player_by_name(name):set_pos(pos)
        minetest.log("action", name.." used /"..k)
        minetest.chat_send_player(name, text)
        return
      end,
    })
end

minetest.register_chatcommand("shop_add", {
    params = "<name>",
    description = "Adds a shop location to the list, only takes effect after a restart!",
    privs = {server=true},

    func = function(name, param)

      if param == "" then
        return false, "Invalid usage, see /help poi_add."
      end

      -- return if name already in use
      if poi.places.shops[param] then
        return false, param.." is already assigned!"
      end

      -- get player position and store using name as key
      local player = minetest.get_player_by_name(name)
      local pos = nil
      if player then
        pos = player:get_pos()
        poi.places.shops[param] = {x=pos.x, y=pos.y, z=pos.z}
        save_data()
        return false, param.." added at "..minetest.pos_to_string(pos)
      else
        return false, "Unable to get position."
      end
    end,
  })

minetest.register_chatcommand("shop_remove", {
    params = "<name>",
    description = "Removes a Point Of Interest from the list",
    privs = {server=true},

    func = function(name, param)

      if param == "" then
        return false, "Invalid usage!"
      end

      -- remove entry
      if poi.places.shops[param] then
        poi.places.shops[param] = nil
        -- save arena to file
        save_data()
        return false, param.." shop removed!"
      else
        -- return if name doesn't exist
        return false, param.." doesn't exist!"

      end
    end,
  })

minetest.register_chatcommand("shop", {
    params = "",
    description = "Lists shops",
    privs = {interact=true},

    func = function(name, param)

      local poiStrings = {}
      for key, value in pairs(poi.places.shops) do
        table.insert(poiStrings, key)
      end
      if #poiStrings == 0 then
        return true, "No shops set!"
      end
      table.insert(poiStrings, "Useage: type /<shop_name> to teleport")
      return true, table.concat(poiStrings, "\n")

    end,
  })

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
        pos = player:get_pos()
        poi.places.poi[param] = {x=pos.x, y=pos.y, z=pos.z}
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
      if poi.places.poi[param] then
        poi.places.poi[param] = nil
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
	if not poi.places.poi then poi.places.poi = {} end
        for key, value in pairs(poi.places.poi) do
	    table.insert(poiStrings, key)
        end
        if #poiStrings == 0 then
          return true, "No Points Of Interest set!"
        end
        return true, table.concat(poiStrings, "\n")
      else
	if poi.places.poi[param] then
	  local player = minetest.get_player_by_name(name)
	  local pos = {x=poi.places.poi[param].x, y=poi.places.poi[param].y, z=poi.places.poi[param].z}
	  -- last check
	  if pos and player then
	    player:set_pos(pos) -- move player to new position
	  end
	else
	  return true, param.." doesn't exist!"
	end
      end
    end,
  })
