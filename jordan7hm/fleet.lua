--Player stat settings
-- 0 - Kills
-- 1 - Deaths
-- 2 - items picked up
-- 3 - current consecutive kills
-- 4 - vehicles destroyed
-- 5 - 
-- 6 - 
-- 7 -
-- 8 - 
-- 9 -- highest consecutive kills

g_word = nil


g_arena = nil -- holds the arena objcet
g_state = nil -- The global arena class, to avoid having to pass it around functions
g_bGameRunning = false -- says whether the game is running or not
g_statsEvent = 0 -- holds the event for displaying stats when the game ends
g_gameTime = nil -- holds the game time
g_event = 0
	

function Arena_OnCreate(arena)
    g_arena = arena
		local cfg = GameSettings()

	cfg.minplayers = 1
	cfg.gamedelay = 15
	
	cfg.str_pregame = "Game starting in "
	cfg.str_noplayers = "Not Enough Players"
	cfg.bDesertedGameEnd = false

	cfg.bIngameTicker = true
	cfg.tckrUpdateSpacing = 1000

	g_state = g_arena:Takeover_State(cfg)
    math.randomseed(os.time())
end

function WipePlayerStats(player)
	player:setstat(0,0)
	player:setstat(1,0)
	player:setstat(2,0) 
	player:setstat(3,0)
	player:setstat(4,0)
	player:setstat(5,0)
	player:setstat(6,0)
	player:setstat(7,0)
	player:setstat(8,0)
	player:setstat(9,0)
end

function Player_OnJoin(player)
    player:message("Welcome to Fleet! " .. player.m_name .. "")
	player:inventory_modify("Miner", 1)
end

function Item_OnPickUp(looter, loot, loot_type, amounttopickup)
	IncreasePickUp(looter)
	return true
end

function DisplayStats(ev)
	--g_bGameRunning = false
	
	local bestKiller = ""
	local bestVictim = ""
	local bestItem = ""
	local bestCon = ""
	local mostKills = 0
	local mostDeaths = 0
	local mostItems = 0
	local mostCon = 0
	
	for x = 1, g_arena:num() do   --This gets the person with most kills
		local player = g_arena:get(x)
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
		
		if (player:getstat(2) > mostItems) then
			mostItems = player:getstat(2)
			bestItem = player.m_name
		elseif (player:getstat(2) == mostItems) then
			bestItem = ("" .. bestItem .. ", " .. player.m_name .. "")
		end
		
		if (player:getstat(9) > mostCon) then
			mostCon = player:getstat(9)
			bestCon = player.m_name
		elseif (player:getstat(9) == mostCon) then
			bestCon = ("" .. bestCon .. ", " .. player.m_name .. "")
		end
		
	end
	
	-------------------------------------------------------------------------
	-- GAME TIME STATISTICS --
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
		g_arena:message("No game is running, weird..")
	end
	------------------------------------------------------------------------
	
	
	------------------------------------------------------------------------
	-- PLAYER STATISTICS --
	if (mostKills == 0) then
		g_arena:message("!_    No one got any kills!")
	else
		g_arena:message("!_    Most Kills: " .. bestKiller .. "(" .. mostKills .. ")")
	end
	
	if (mostCon == 0) then
		g_arena:message("!_    No one got any consecutive kills!")
	else
		g_arena:message("!_    Most Consecutive Kills: " .. bestCon .. "(" .. mostCon .. ")")
	end
	
	if (mostItems == 0) then
		g_arena:message("!_    No one picked any items up!")
	else
		g_arena:message("!_    Most Items Picked Up: " .. bestItem .. "(" .. mostItems .. ")")
	end
	
	if (mostDeaths == 0) then
		g_arena:message("!_    No one got any deaths!")
	else
		g_arena:message("!_    Most Deaths: " .. bestVictim .. "(" .. mostDeaths .. ")")
	end
	------------------------------------------------------------------------
end


function Arena_OnGameEnd()
	local blah = 0
	g_statsEvent = event_create(DisplayStats, 1000, g_arena)
		for x = 1, g_arena:num() do
		local player = g_arena:get(x)
		player:spec()
		player:inventory_modify("Miner", 1)
	end
end

function Arena_OnGameStart()
	g_bGameRunning = true
	g_gameTime = os.time()	
	for x = 1, g_arena:num() do
		local player = g_arena:get(x)
		WipePlayerStats(player)
		player:inventory_modify("Miner", 1)
	end
end

function Player_OnDeath(killer, victim)
	if (g_bGameRunning == false) then -- if the game isn't running, don't record stats
		return
	elseif (killer:valid() == false) then -- if the killer was a turret/terrain we just increase the death count
		IncreaseDeath(victim) 
		return
	elseif (killer.m_name == victim.m_name) then -- if the player killed themself we just increase the death count
		IncreaseDeath(victim)
		return
	end
	
	-- else one player killed another player, so we increase the kill count and death count respectively
	IncreaseKill(killer)
	IncreaseDeath(victim)
end

function IncreaseKill(killer)
	killer:setstat(0,(killer:getstat(0) + 1)) -- increase kills
	killer:setstat(3,(killer:getstat(3) + 1)) -- increase consec kills
	if (killer:getstat(3) > killer:getstat(9)) then -- if current consec kills is greater than highest consec kills, replace it
		killer:setstat(9,killer:getstat(3))
	end
end

function IncreaseDeath(victim)
	victim:setstat(1,(victim:getstat(1) + 1)) -- increase deaths
	victim:setstat(3,0) -- reset consecutive kills
end

function IncreasePickUp(looter)
	looter:setstat(2,(looter:getstat(2) + 1))
end

function Vehicle_OnDeath(victim, killer, itemid)
	local vid = victim:vehicletypeid()
	if (victim:vehicletypeid() == 401) then -- Collective command
	g_state:Endgame()
	g_arena:message("Collective's Command Center has been destroyed! Titan wins!")
	elseif (victim:vehicletypeid() == 411) then -- Titan command
	g_state:Endgame()
	g_arena:message("Titan's Command Center has been destroyed! Collective wins!")
	elseif (vid == 417) then
	local c = victim:coords()
	g_arena:item_create("Eljaycium Ore", 1, c.x + 104, c.y + 102)
	g_arena:item_create("Eljaycium Ore", 1, c.x + 112, c.y - 114)
	g_arena:item_create("Eljaycium Ore", 1, c.x - 112, c.y + 106)
	g_arena:item_create("Eljaycium Ore", 1, c.x - 103, c.y - 106)
	end	
	return true
end

function Player_OnUnspec(visitor)
visitor:inventory_modify("Miner", 1)
return true
end

function DisplayCoords()
	h = g_arena:getPlayer("HellSpawn"):coords()
	g_arena:message("x = " .. h.x .. " y = " .. h.y .. "")
end


