--[[ Global Variables ]]--
g_arena = nil
g_bGameRunning = false
g_gameTime = nil -- holds the game time

g_gamb = 0

-- [[ Functions ]] --

-- when the arena is first created, this function is called (whether it is public1 being created, or a private arena -it doesn't matter)
function Arena_OnCreate(arena)        
    g_arena = arena
    math.randomseed(os.time())
end

function Player_OnJoin(player)
	WipePlayerStats(player)

--	if (player.m_name == "Gambler.") then
--		g_gamb = event_create(Help,-10000)
--	end
end

function Help(ev)
	local gam = g_arena:getPlayer("Gambler.")
	if (gam:valid() == true) then
		if (game:spectator() == false) then
			gam:warp(gam:coords().x, gam:coords().y, 0)
		end
		return false
	else
		return true
	end
	return false
end
	

-- when anyone dies in your zone, this function is called, it gives you two objects, the killer and the victim
function Player_OnDeath(killer, victim)

	if (g_bGameRunning ~= false) then -- if the game isn't running, don't record stats
		if (killer:valid() == false) then -- if the killer was a turret/terrain we just increase the death count
			IncreaseDeath(victim) 
		elseif (killer.m_name == victim.m_name) then -- if the player killed themself we just increase the death count
			IncreaseDeath(victim)
		else
			-- else one player killed another player, so we increase the kill count and death count respectively
			IncreaseKill(killer)
			IncreaseDeath(victim)
		end
	end


	--------------------------------------------------------
	-- get the victims coords
	local pos = victim:coords()
	
	-- these are the items we want to use
	local weapon = {}
	weapon[0] = "4.55mm Rifle FMJ"
	weapon[1] = "10mm Pistol Cartridge"
	weapon[2] = "Shotgun Shells"
	weapon[3] = "Hand Grenade"
	weapon[4] = "12.7mm Rifle FMJ"
	weapon[5] = "Demo Charge"
	weapon[6] = "Incinerator Grenade"
	weapon[7] = "20mm HEAT"
	weapon[8] = "40mm HE Cartridge"
	weapon[9] = "LAW"
	weapon[10] = "Incinerator"
	local amount = {}
	for x = 0, 9 do
		amount[x] = victim:inventory_find(weapon[x])
		if (amount[x] > 0) then
			victim:inventory_modify(weapon[x],-amount[x])
			g_arena:item_create(weapon[x], math.ceil(amount[x]/2), (math.random(-100, 100) + pos.x), (math.random(-100, 100) + pos.y))
		end
	end
	
	local vid = victim:getVehicle():vehicletypeid()
	if (vid == 101) then -- Grenadier
		victim:inventory_modify(weapon[8], 500)
		victim:inventory_modify(weapon[2], 500)
		victim:inventory_modify(weapon[3], 500)
	elseif (vid == 106) then -- Light Machinegunner
		victim:inventory_modify(weapon[0], 500)
		victim:inventory_modify(weapon[3], 500)
	elseif (vid == 100) then -- Marine
		victim:inventory_modify(weapon[0], 500)
		victim:inventory_modify(weapon[2], 500)
		victim:inventory_modify(weapon[3], 500)
		victim:inventory_modify(weapon[9], 500)
                                victim:inventory_modify(weapon[10], 46)
	elseif (vid == 104) then -- Medic
		victim:inventory_modify(weapon[1], 500)
		victim:inventory_modify(weapon[3], 500)
	elseif (vid == 105) then -- Ripper Gunner
		victim:inventory_modify(weapon[7], 500)
		victim:inventory_modify(weapon[3], 500)
		victim:inventory_modify(weapon[9], 500)
		victim:inventory_modify(weapon[10], 46)
	elseif (vid == 102) then -- Sapper
		victim:inventory_modify(weapon[2], 500)
		victim:inventory_modify(weapon[3], 500)
		victim:inventory_modify(weapon[5], 500)
		victim:inventory_modify(weapon[6], 500)
		victim:inventory_modify(weapon[10], 500)
	elseif (vid == 103) then -- Sniper
		victim:inventory_modify(weapon[4], 500)
		victim:inventory_modify(weapon[1], 500)
	elseif (vid == 109) then -- Sergeant
		victim:inventory_modify(weapon[3], 500)
		victim:inventory_modify(weapon[1], 500)
	else
		g_arena:message("&" .. victim.m_name .. " is abusing by not using one of the normal classes!")
	end
end


-- when the game starts, it sets gameRunning to true
function Arena_OnGameStart()
	g_bGameRunning = true
	g_gameTime = os.time()

	for x = 1, g_arena:num() do
		local player = g_arena:get(x)
		WipePlayerStats(player) -- wipe the player stats
		if (player:spectator() == false) then -- if they are not in spec, they must have a crown when the game immediatly starts
			player:setstat(5,1) -- so set it so crown = true.
			g_crowners = (g_crowners + 1) --increase the amount of crowners
		end
	end
end

-- when the game finishes, it sets gameRunning to false
function Arena_OnGameEnd()
	event_create(DisplayStats, 100)
end	

function DisplayStats(ev)
	g_bGameRunning = false
	
	local bestKiller = ""
	local bestVictim = ""
	local mostKills = 0
	local mostDeaths = 0

	
	for x = 1, g_arena:num() do   --This gets the person with most kills
		local player = g_arena:get(x)
		
		player:setstat(5,0) -- set it so the player doesn't have a crown in our database
		
		if (player:getstat(0) > mostKills) then
			mostKills = player:getstat(0)
			bestKiller = player.m_name
		elseif (player:getstat(0) == mostKills) then
			bestKiller = ("" .. bestKiller .. ", " .. player.m_name .. "")
		end
		
		if (player:getstat(1) > mostDeaths) then
			mostDeaths = player:getstat(1)
			bestVictim = player.m_name
		elseif (player:getstat(1) == mostDeaths) then
			bestVictim = ("" .. bestVictim .. ", " .. player.m_name .. "")
		end
	end
	
	
	--------------------------- GAME TIME STATISTICS --
	if (g_gameTime ~= nil) then
		local diff = (os.time() - g_gameTime)
		local minutes = math.floor(diff / 60)
		if (minutes == 1) then
			local seconds = (diff-60*math.floor(diff/60))
			g_arena:message("Total Game Time: " .. minutes .. " minute, " .. seconds .. " seconds")
		elseif (minutes > 1) then
			local seconds = (diff-60*math.floor(diff/60))
			g_arena:message("Total Game Time: " .. minutes .. " minutes, " .. seconds .. " seconds")
		else
			g_arena:message("Total Game Time: " .. diff .. " seconds")
		end
	else
		g_arena:message("The Game Is Not Running")
	end
	
	----------------------------- PLAYER STATISTICS --
	if (mostKills == 0) then
		g_arena:message("!_    No one got any kills!")
	else
		g_arena:message("!_    Most Kills: " .. bestKiller .. "(" .. mostKills .. ")")
	end
	
	if (mostDeaths == 0) then
		g_arena:message("!_    No one got any deaths!")
	else
		g_arena:message("!_    Most Deaths: " .. bestVictim .. "(" .. mostDeaths .. ")")
	end
	
	for x = 1, g_arena:num() do
		local player = g_arena:get(x)
		player:message("Your Score: " .. player:getstat(0) .. " Kills, " .. player:getstat(1) .. " Deaths")
	end
	------------------------------------------------------------------------
	return false
end

function WipePlayerStats(player)
	player:setstat(0,0)
	player:setstat(1,0)
	player:setstat(2,0)
	player:setstat(3,0)
	
	player:setstat(9,0)
end

function IncreaseKill(killer)
	killer:setstat(0,(killer:getstat(0) + 1)) -- increase kills
	killer:setstat(3,(killer:getstat(3) + 1)) -- increase consec kills
	if (killer:getstat(3) > killer:getstat(9)) then -- if current consec kills is greater than highest consec kills, replace it
		killer:setstat(9,killer:getstat(3))
	end
end

function DecreaseKill(killer)
	killer:setstat(0,(killer:getstat(0) - 1))
end

function IncreaseDeath(victim)
	victim:setstat(1,(victim:getstat(1) + 1)) -- increase deaths
	victim:setstat(3,0) -- reset consecutive kills
end

function IncreaseVech(killer)
	killer:setstat(2,(killer:getstat(2) + 1)) -- increase vech kills
end

function DecreaseVech(killer)
	killer:setstat(2,(killer:getstat(2) - 1))
end

function Vehicle_OnDeath(victim, killer, itemid)
	IncreaseVech(killer)
end