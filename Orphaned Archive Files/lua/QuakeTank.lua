--[[ Global Variables ]]--
g_arena = nil



-- [[ Functions ]] --

-- when the arena is first created, this function is called (whether it is public1 being created, or a private arena -it doesn't matter)
function Arena_OnCreate(arena)        
    g_arena = arena
    math.randomseed(os.time())
end	

-- when anyone dies in your zone, this function is called, it gives you two objects, the killer and the victim
function Player_OnDeath(killer, victim)

	--------------------------------------------------------
	-- get the victims coords
	local pos = victim:coords()
	
	-- these are the items we want to use
	local weapon = {}
	weapon[1] = ""
	weapon[2] = ""
	weapon[3] = ""
	weapon[4] = ""
	weapon[5] = ""
	weapon[6] = ""
	weapon[7] = ""
	weapon[8] = ""
	weapon[9] = ""
	weapon[10] = ""
-- add more items here as needed, make sure you change the for line below
	weapon[20] = "TankPrizeA"
	local amount = {}

--	for x = 1, 10 do
--		amount[x] = victim:inventory_find(weapon[x])
--		if (amount[x] > 0) then
--			local modifyamount = math.ceil(math.random(15, 30) * amount[x] / 100)
--			victim:inventory_modify(weapon[x], -modifyamount)
--			g_arena:item_create(weapon[x], modifyamount, (math.random(-100, 100) + pos.x), (math.random(-100, 100) + pos.y))
--		end
--	end

	for x = 20, 20 do
		g_arena:item_create(weapon[x], 1, (math.random(-50, 50) + pos.x), (math.random(-50, 50) + pos.y))				
	end
end