-- Minetest 0.4 mod: stairs
-- See README.txt for licensing and other information.
local init = os.clock()
stairs = {}

-- Node will be called stairs:stair_<subname>
function stairs.register_stair(subname, recipeitem, groups, images, description, sounds)
	minetest.register_node(":stairs:stair_" .. subname, {
		description = description,
		drawtype = "nodebox",
		tiles = images,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = true,
		groups = groups,
		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5},
				{-0.5, 0, 0, 0.5, 0.5, 0.5},
			},
		},
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return itemstack
			end
			
			local p0 = pointed_thing.under
			local p1 = pointed_thing.above
			if p0.y-1 == p1.y then
				local fakestack = ItemStack("stairs:stair_" .. subname.."upside_down")
				local ret = minetest.item_place(fakestack, placer, pointed_thing)
				if ret:is_empty() then
					itemstack:take_item()
					return itemstack
				end
			end
			local futurpos = pointed_thing.under
			local frontstair = {x=futurpos.x-1, y=futurpos.y+1, z=futurpos.z} 
			local leftstair = {x=futurpos.x, y=futurpos.y+1, z=futurpos.z+1} 
			print( minetest.get_node(frontstair).name)
			if minetest.get_node(frontstair).name == "stairs:stair_"..subname.."" and minetest.get_node(leftstair).name == "stairs:stair_"..subname.."" then
				local fakestack = ItemStack("stairs:stair_" .. subname.."_corner_1")
				local ret = minetest.item_place(fakestack, placer, pointed_thing)
				if ret:is_empty() then
					itemstack:take_item()
					return itemstack
				end
			end 
			
			-- Otherwise place regularly
			return minetest.item_place(itemstack, placer, pointed_thing)
		end,
	})
	
	minetest.register_node(":stairs:stair_" .. subname.."upside_down", {
		drop = "stairs:stair_" .. subname,
		drawtype = "nodebox",
		tiles = images,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = true,
		groups = groups,
		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, 0, -0.5, 0.5, 0.5, 0.5},
				{-0.5, -0.5, 0, 0.5, 0, 0.5},
			},
		},
	})

	minetest.register_node(":stairs:stair_" .. subname.."_corner_1", {
		drop = "stairs:stair_" .. subname,
		drawtype = "nodebox",
		tiles = images,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = true,
		groups = groups,
		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0, 0.5}, 
				{-0.5, -0, -0, 0, 0.5, 0.5}, 
			},
		},
	})

	minetest.register_craft({
		output = 'stairs:stair_' .. subname .. ' 4',
		recipe = {
			{recipeitem, "", ""},
			{recipeitem, recipeitem, ""},
			{recipeitem, recipeitem, recipeitem},
		},
	})

	-- Flipped recipe for the silly minecrafters
	minetest.register_craft({
		output = 'stairs:stair_' .. subname .. ' 4',
		recipe = {
			{"", "", recipeitem},
			{"", recipeitem, recipeitem},
			{recipeitem, recipeitem, recipeitem},
		},
	})
end

-- Node will be called stairs:slab_<subname>
function stairs.register_slab(subname, recipeitem, groups, images, description, sounds)
	minetest.register_node(":stairs:slab_" .. subname, {
		description = description,
		drawtype = "nodebox",
		tiles = images,
		paramtype = "light",
		is_ground_content = true,
		groups = groups,
		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
		},
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return itemstack
			end

			-- If it's being placed on an another similar one, replace it with
			-- a full block
			local slabpos = nil
			local slabnode = nil
			local p0 = pointed_thing.under
			local p1 = pointed_thing.above
			local n0 = minetest.get_node(p0)
			if n0.name == "stairs:slab_" .. subname and
					p0.y+1 == p1.y then
				slabpos = p0
				slabnode = n0
			end
			if slabpos then
				-- Remove the slab at slabpos
				minetest.remove_node(slabpos)
				-- Make a fake stack of a single item and try to place it
				local fakestack = ItemStack(recipeitem)
				pointed_thing.above = slabpos
				fakestack = minetest.item_place(fakestack, placer, pointed_thing)
				-- If the item was taken from the fake stack, decrement original
				if not fakestack or fakestack:is_empty() then
					itemstack:take_item(1)
				-- Else put old node back
				else
					minetest.set_node(slabpos, slabnode)
				end
				return itemstack
			end
			
			-- Upside down slabs
			if p0.y-1 == p1.y then
				-- Turn into full block if pointing at a existing slab
				if n0.name == "stairs:slab_" .. subname.."upside_down" then
					-- Remove the slab at the position of the slab
					minetest.remove_node(p0)
					-- Make a fake stack of a single item and try to place it
					local fakestack = ItemStack(recipeitem)
					pointed_thing.above = p0
					fakestack = minetest.item_place(fakestack, placer, pointed_thing)
					-- If the item was taken from the fake stack, decrement original
					if not fakestack or fakestack:is_empty() then
						itemstack:take_item(1)
					-- Else put old node back
					else
						minetest.set_node(p0, n0)
					end
					return itemstack
				end
				
				-- Place upside down slab
				local fakestack = ItemStack("stairs:slab_" .. subname.."upside_down")
				local ret = minetest.item_place(fakestack, placer, pointed_thing)
				if ret:is_empty() then
					itemstack:take_item()
					return itemstack
				end
			end
			
			-- If pointing at the side of a upside down slab
			if n0.name == "stairs:slab_" .. subname.."upside_down" and
					p0.y+1 ~= p1.y then
				-- Place upside down slab
				local fakestack = ItemStack("stairs:slab_" .. subname.."upside_down")
				local ret = minetest.item_place(fakestack, placer, pointed_thing)
				if ret:is_empty() then
					itemstack:take_item()
					return itemstack
				end
			end
			
			-- Otherwise place regularly
			return minetest.item_place(itemstack, placer, pointed_thing)
		end,
	})
	
	minetest.register_node(":stairs:slab_" .. subname.."upside_down", {
		drop = "stairs:slab_"..subname,
		drawtype = "nodebox",
		tiles = images,
		paramtype = "light",
		stack_max = 64,
		paramtype2 = "facedir",
		on_place = minetest.rotate_node,
		is_ground_content = true,
		groups = groups,
		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {-0.5, 0, -0.5, 0.5, 0.5, 0.5},
		},
	})

	minetest.register_craft({
		output = 'stairs:slab_' .. subname .. ' 6',
		recipe = {
			{recipeitem, recipeitem, recipeitem},
		},
	})
end

-- Nodes will be called stairs:{stair,slab}_<subname>
function stairs.register_stair_and_slab(subname, recipeitem, groups, images, desc_stair, desc_slab, sounds)
	stairs.register_stair(subname, recipeitem, groups, images, desc_stair, sounds)
	stairs.register_slab(subname, recipeitem, groups, images, desc_slab, sounds)
end

stairs.register_stair_and_slab("wood", "default:wood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3},
		{"default_wood.png"},
		"Wooden Stair",
		"Wooden Slab",
		default.node_sound_wood_defaults())
		
stairs.register_stair_and_slab("junglewood", "default:junglewood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3},
		{"default_junglewood.png"},
		"Junglewood Stair",
		"Junglewood Slab",
		default.node_sound_wood_defaults())
		
stairs.register_stair_and_slab("acaciawood", "default:acaciawood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3},
		{"default_acaciawood.png"},
		"Acaciawood Stair",
		"Acaciawood Slab",
		default.node_sound_wood_defaults())
		
stairs.register_stair_and_slab("sprucewood", "default:sprucewood",
		{snappy=2,choppy=2,oddly_breakable_by_hand=2,flammable=3},
		{"default_sprucewood.png"},
		"Sprucewood Stair",
		"Sprucewood Slab",
		default.node_sound_wood_defaults())

stairs.register_stair_and_slab("stone", "default:stone",
		{cracky=3},
		{"default_stone.png"},
		"Stone Stair",
		"Stone Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("cobble", "default:cobble",
		{cracky=3},
		{"default_cobble.png"},
		"Cobble Stair",
		"Cobble Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("brick", "default:brick",
		{cracky=3},
		{"default_brick.png"},
		"Brick Stair",
		"Brick Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("sandstone", "default:sandstone",
		{crumbly=2,cracky=2},
		{"default_sandstone_top.png", "default_sandstone_bottom.png", "default_sandstone_normal.png"},
		"Sandstone Stair",
		"Sandstone Slab",
		default.node_sound_stone_defaults())

stairs.register_stair_and_slab("stonebrick", "default:stonebrick",
		{cracky=3},
		{"default_stone_brick.png"},
		"Stone Brick Stair",
		"Stone Brick Slab",
		default.node_sound_stone_defaults()
)

stairs.register_stair_and_slab("quartzblock", "default:quartz_block",
	{snappy=1,bendy=2,cracky=1,level=2},
	{"default_quartz_block_top.png", "default_quartz_block_bottom.png", "default_quartz_block_side.png"},
	"Quartz stair",
	"Quartz slab",
	default.node_sound_stone_defaults()
)

stairs.register_slab("quartzstair", "default:quartz_pillar",
	{snappy=1,bendy=2,cracky=1,level=2},
	{"default_quartz_pillar_top.png", "default_quartz_pillar_top.png", "default_quartz_pillar_side.png"},
	"Quartz Pillar stair",
	"Quartz Pillar slab",
	default.node_sound_stone_defaults()
)	
		
local time_to_load= os.clock() - init
print(string.format("[MOD] "..minetest.get_current_modname().." loaded in %.4f s", time_to_load))
