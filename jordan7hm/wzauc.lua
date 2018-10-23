-- dz --
g_arena = nil
g_bGameRunning = false
speccerAmount = 0
    
function Arena_OnCreate(arena)        
    g_arena = arena        
    math.randomseed(os.time())
end


--function Player_OnDeath(killer, victim)
--victim:inventory_modify("Energy Cells",600)
--end


--function Player_OnJoin(player)
--
--end

--function Player_OnLeave(departee)
--
--end

--function Item_OnPickUp(p, i, at, amount)
--	return true
--end

--function Vehicle_OnProduce(p, menuitem)
--	return true
--end

function Arena_OnGameStart()
	g_bGameRunning = true
end

function Arena_OnGameEnd()
	g_bGameRunning = false
end
