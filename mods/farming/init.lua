local init = os.clock()
farming = {}

function farming:add_plant(full_grown, names, interval, chance)
	minetest.register_abm({
		nodenames = names,
		interval = interval,
		chance = chance,
		action = function(pos, node)
			pos.y = pos.y-1
			if minetest.env:get_node(pos).name ~= "farming:soil_wet" and math.random(0, 9) > 0 then
				return
			end
			pos.y = pos.y+1
			if not minetest.env:get_node_light(pos) then
				return
			end
			if minetest.env:get_node_light(pos) < 10 then
				return
			end
			local step = nil
			for i,name in ipairs(names) do
				if name == node.name then
					step = i
					break
				end
			end
			if step == nil then
				return
			end
			local new_node = {name=names[step+1]}
			if new_node.name == nil then
				new_node.name = full_grown
			end
			minetest.env:set_node(pos, new_node)
		end
}	)
end


function farming:place_seed(itemstack, placer, pointed_thing, plantname)
	local pt = pointed_thing
	if not pt then
		return
	end
	if pt.type ~= "node" then
		return
	end
	
	local pos = {x=pt.above.x, y=pt.above.y-1, z=pt.above.z}
	local farmland = minetest.env:get_node(pos)
	pos= {x=pt.above.x, y=pt.above.y, z=pt.above.z}
	local place_s = minetest.env:get_node(pos)

	
	if string.find(farmland.name, "farming:soil") and string.find(place_s.name, "air")  then
		minetest.env:add_node(pos, {name=plantname})
	else
		return
	end

	if not minetest.setting_getbool("creative_mode") then
		itemstack:take_item()
	end
	return itemstack
end



-- ========= SOIL =========
dofile(minetest.get_modpath("farming").."/soil.lua")

-- ========= HOES =========
dofile(minetest.get_modpath("farming").."/hoes.lua")

-- ========= WHEAT =========
dofile(minetest.get_modpath("farming").."/wheat.lua")

-- ========= PUMPKIN =========
dofile(minetest.get_modpath("farming").."/pumpkin.lua")

-- ========= MELON =========
dofile(minetest.get_modpath("farming").."/melon.lua")

-- ========= CARROT =========
dofile(minetest.get_modpath("farming").."/carrots.lua")

-- ========= POTATOES =========
dofile(minetest.get_modpath("farming").."/potatoes.lua")

-- ========= MUSHROOMS =========
dofile(minetest.get_modpath("farming").."/mushrooms.lua")

local time_to_load= os.clock() - init
print(string.format("[MOD] "..minetest.get_current_modname().." loaded in %.4f s", time_to_load))
