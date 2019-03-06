g_arena = nil	

function Arena_OnCreate(arena)        
        g_arena = arena        
        math.randomseed(os.time())
end

--function Player_OnUnspec(visitor)
--	g_arena:message("Unspecced")
--	return true
--end

--function Vehicle_OnDeath(victim, killer, itemid) -- Wreckage appears around where the structure was blown up		
--end

function Player_OnDeath(killer, victim) -- removes items from the players inventory when they die 
	victim:inventory_modify("MIRV Missile", -3)
	victim:inventory_modify("BioShrapnel Bomb", -3)
	victim:inventory_modify("Moltor ClusterBomb", -3)
	victim:inventory_modify("Ripper Field", -3)
	victim:inventory_modify("Bio Burst", -3)
	victim:inventory_modify("Cluster Burst", -3)
	victim:inventory_modify("Shard Mine", -3)
	victim:inventory_modify("Skithzar Cluster Mine", -3)
	victim:inventory_modify("Mega Moltor Mine", -3)
	victim:inventory_modify("Terran ECM", -3)
	victim:inventory_modify("ECM Device", -3)
	victim:inventory_modify("Stealth", -3)
	victim:inventory_modify("Repulsor", -3)
end


function Player_OnJoin(player)
    player:message("&Welcome to Rift Ball, " .. player.m_name .. ". This is a settings test, please be patient.")
end


function Item_OnPickUp(looter, loot, loot_type, amounttopickup)	
	if (loot_type.m_name == "SuperBomb") then
		if (looter:getVehicle():vehicletypeid() == 107) then
			looter:inventory_modify("MIRV Missile", 1)
		elseif (looter:getVehicle():vehicletypeid() == 106) then
			looter:inventory_modify("MIRV Missile", 1)
		elseif (looter:getVehicle():vehicletypeid() == 101) then
			looter:inventory_modify("MIRV Missile", 1)
		elseif (looter:getVehicle():vehicletypeid() == 108) then
			looter:inventory_modify("MIRV Missile", 1)
		elseif (looter:getVehicle():vehicletypeid() == 105) then
			looter:inventory_modify("BioShrapnel Bomb", 1)
		elseif (looter:getVehicle():vehicletypeid() == 100) then
			looter:inventory_modify("BioShrapnel Bomb", 1)
		elseif (looter:getVehicle():vehicletypeid() == 103) then
			looter:inventory_modify("BioShrapnel Bomb", 1)
		elseif (looter:getVehicle():vehicletypeid() == 104) then
			looter:inventory_modify("BioShrapnel Bomb", 1)
		elseif (looter:getVehicle():vehicletypeid() == 102) then
			looter:inventory_modify("Moltor ClusterBomb", 1)
		elseif (looter:getVehicle():vehicletypeid() == 109) then
			looter:inventory_modify("Moltor ClusterBomb", 1)
		elseif (looter:getVehicle():vehicletypeid() == 110) then
			looter:inventory_modify("Moltor ClusterBomb", 1)
		elseif (looter:getVehicle():vehicletypeid() == 111) then
			looter:inventory_modify("Moltor ClusterBomb", 1)
		elseif (looter:getVehicle():vehicletypeid() == 207) then
			looter:inventory_modify("MIRV Missile", 1)
		elseif (looter:getVehicle():vehicletypeid() == 206) then
			looter:inventory_modify("MIRV Missile", 1)
		elseif (looter:getVehicle():vehicletypeid() == 201) then
			looter:inventory_modify("MIRV Missile", 1)
		elseif (looter:getVehicle():vehicletypeid() == 208) then
			looter:inventory_modify("MIRV Missile", 1)
		elseif (looter:getVehicle():vehicletypeid() == 205) then
			looter:inventory_modify("BioShrapnel Bomb", 1)
		elseif (looter:getVehicle():vehicletypeid() == 200) then
			looter:inventory_modify("BioShrapnel Bomb", 1)
		elseif (looter:getVehicle():vehicletypeid() == 203) then
			looter:inventory_modify("BioShrapnel Bomb", 1)
		elseif (looter:getVehicle():vehicletypeid() == 204) then
			looter:inventory_modify("BioShrapnel Bomb", 1)
		elseif (looter:getVehicle():vehicletypeid() == 202) then
			looter:inventory_modify("Moltor ClusterBomb", 1)
		elseif (looter:getVehicle():vehicletypeid() == 209) then
			looter:inventory_modify("Moltor ClusterBomb", 1)
		elseif (looter:getVehicle():vehicletypeid() == 210) then
			looter:inventory_modify("Moltor ClusterBomb", 1)
		elseif (looter:getVehicle():vehicletypeid() == 211) then
			looter:inventory_modify("Moltor ClusterBomb", 1)
		else
		end

	elseif (loot_type.m_name == "SuperBurst") then
		if (looter:getVehicle():vehicletypeid() == 107) then
			looter:inventory_modify("Ripper Field", 1)
		elseif (looter:getVehicle():vehicletypeid() == 106) then
			looter:inventory_modify("Ripper Field", 1)
		elseif (looter:getVehicle():vehicletypeid() == 101) then
			looter:inventory_modify("Ripper Field", 1)
		elseif (looter:getVehicle():vehicletypeid() == 108) then
			looter:inventory_modify("Ripper Field", 1)
		elseif (looter:getVehicle():vehicletypeid() == 105) then
			looter:inventory_modify("Bio Burst", 1)
		elseif (looter:getVehicle():vehicletypeid() == 100) then
			looter:inventory_modify("Bio Burst", 1)
		elseif (looter:getVehicle():vehicletypeid() == 103) then
			looter:inventory_modify("Bio Burst", 1)
		elseif (looter:getVehicle():vehicletypeid() == 104) then
			looter:inventory_modify("Bio Burst", 1)
		elseif (looter:getVehicle():vehicletypeid() == 102) then
			looter:inventory_modify("Cluster Burst", 1)
		elseif (looter:getVehicle():vehicletypeid() == 109) then
			looter:inventory_modify("Cluster Burst", 1)
		elseif (looter:getVehicle():vehicletypeid() == 110) then
			looter:inventory_modify("Cluster Burst", 1)
		elseif (looter:getVehicle():vehicletypeid() == 111) then
			looter:inventory_modify("Cluster Burst", 1)
		elseif (looter:getVehicle():vehicletypeid() == 207) then
			looter:inventory_modify("Ripper Field", 1)
		elseif (looter:getVehicle():vehicletypeid() == 206) then
			looter:inventory_modify("Ripper Field", 1)
		elseif (looter:getVehicle():vehicletypeid() == 201) then
			looter:inventory_modify("Ripper Field", 1)
		elseif (looter:getVehicle():vehicletypeid() == 208) then
			looter:inventory_modify("Ripper Field", 1)
		elseif (looter:getVehicle():vehicletypeid() == 205) then
			looter:inventory_modify("Bio Burst", 1)
		elseif (looter:getVehicle():vehicletypeid() == 200) then
			looter:inventory_modify("Bio Burst", 1)
		elseif (looter:getVehicle():vehicletypeid() == 203) then
			looter:inventory_modify("Bio Burst", 1)
		elseif (looter:getVehicle():vehicletypeid() == 204) then
			looter:inventory_modify("Bio Burst", 1)
		elseif (looter:getVehicle():vehicletypeid() == 202) then
			looter:inventory_modify("Cluster Burst", 1)
		elseif (looter:getVehicle():vehicletypeid() == 209) then
			looter:inventory_modify("Cluster Burst", 1)
		elseif (looter:getVehicle():vehicletypeid() == 210) then
			looter:inventory_modify("Cluster Burst", 1)
		elseif (looter:getVehicle():vehicletypeid() == 211) then
			looter:inventory_modify("Cluster Burst", 1)
		else
		end
		
	elseif (loot_type.m_name == "SuperMine") then
		if (looter:getVehicle():vehicletypeid() == 107) then
			looter:inventory_modify("Shard Mine", 1)
		elseif (looter:getVehicle():vehicletypeid() == 106) then
			looter:inventory_modify("Shard Mine", 1)
		elseif (looter:getVehicle():vehicletypeid() == 101) then
			looter:inventory_modify("Shard Mine", 1)
		elseif (looter:getVehicle():vehicletypeid() == 108) then
			looter:inventory_modify("Shard Mine", 1)
		elseif (looter:getVehicle():vehicletypeid() == 105) then
			looter:inventory_modify("Skithzar Cluster Mine", 1)
		elseif (looter:getVehicle():vehicletypeid() == 100) then
			looter:inventory_modify("Skithzar Cluster Mine", 1)
		elseif (looter:getVehicle():vehicletypeid() == 103) then
			looter:inventory_modify("Skithzar Cluster Mine", 1)
		elseif (looter:getVehicle():vehicletypeid() == 104) then
			looter:inventory_modify("Skithzar Cluster Mine", 1)
		elseif (looter:getVehicle():vehicletypeid() == 102) then
			looter:inventory_modify("Mega Moltor Mine", 1)
		elseif (looter:getVehicle():vehicletypeid() == 109) then
			looter:inventory_modify("Mega Moltor Mine", 1)
		elseif (looter:getVehicle():vehicletypeid() == 110) then
			looter:inventory_modify("Mega Moltor Mine", 1)
		elseif (looter:getVehicle():vehicletypeid() == 111) then
			looter:inventory_modify("Mega Moltor Mine", 1)
		elseif (looter:getVehicle():vehicletypeid() == 207) then
			looter:inventory_modify("Shard Mine", 1)
		elseif (looter:getVehicle():vehicletypeid() == 206) then
			looter:inventory_modify("Shard Mine", 1)
		elseif (looter:getVehicle():vehicletypeid() == 201) then
			looter:inventory_modify("Shard Mine", 1)
		elseif (looter:getVehicle():vehicletypeid() == 208) then
			looter:inventory_modify("Shard Mine", 1)
		elseif (looter:getVehicle():vehicletypeid() == 205) then
			looter:inventory_modify("Skithzar Cluster Mine", 1)
		elseif (looter:getVehicle():vehicletypeid() == 200) then
			looter:inventory_modify("Skithzar Cluster Mine", 1)
		elseif (looter:getVehicle():vehicletypeid() == 203) then
			looter:inventory_modify("Skithzar Cluster Mine", 1)
		elseif (looter:getVehicle():vehicletypeid() == 204) then
			looter:inventory_modify("Skithzar Cluster Mine", 1)
		elseif (looter:getVehicle():vehicletypeid() == 202) then
			looter:inventory_modify("Mega Moltor Mine", 1)
		elseif (looter:getVehicle():vehicletypeid() == 209) then
			looter:inventory_modify("Mega Moltor Mine", 1)
		elseif (looter:getVehicle():vehicletypeid() == 210) then
			looter:inventory_modify("Mega Moltor Mine", 1)
		elseif (looter:getVehicle():vehicletypeid() == 211) then
			looter:inventory_modify("Mega Moltor Mine", 1)
		else
		end
		
	elseif (loot_type.m_name == "ECM Prize") then
		if (looter:getVehicle():vehicletypeid() == 107) then
			looter:inventory_modify("Terran ECM", 1)
		elseif (looter:getVehicle():vehicletypeid() == 106) then
			looter:inventory_modify("Terran ECM", 1)
		elseif (looter:getVehicle():vehicletypeid() == 101) then
			looter:inventory_modify("Terran ECM", 1)
		elseif (looter:getVehicle():vehicletypeid() == 108) then
			looter:inventory_modify("Terran ECM", 1)
		elseif (looter:getVehicle():vehicletypeid() == 105) then
			looter:inventory_modify("ECM Device", 1)
		elseif (looter:getVehicle():vehicletypeid() == 100) then
			looter:inventory_modify("ECM Device", 1)
		elseif (looter:getVehicle():vehicletypeid() == 103) then
			looter:inventory_modify("ECM Device", 1)
		elseif (looter:getVehicle():vehicletypeid() == 104) then
			looter:inventory_modify("ECM Device", 1)
		elseif (looter:getVehicle():vehicletypeid() == 102) then
			looter:inventory_modify("ECM Device", 1)
		elseif (looter:getVehicle():vehicletypeid() == 109) then
			looter:inventory_modify("ECM Device", 1)
		elseif (looter:getVehicle():vehicletypeid() == 110) then
			looter:inventory_modify("ECM Device", 1)
		elseif (looter:getVehicle():vehicletypeid() == 111) then
			looter:inventory_modify("ECM Device", 1)
		elseif (looter:getVehicle():vehicletypeid() == 207) then
			looter:inventory_modify("Terran ECM", 1)
		elseif (looter:getVehicle():vehicletypeid() == 206) then
			looter:inventory_modify("Terran ECM", 1)
		elseif (looter:getVehicle():vehicletypeid() == 201) then
			looter:inventory_modify("Terran ECM", 1)
		elseif (looter:getVehicle():vehicletypeid() == 208) then
			looter:inventory_modify("Terran ECM", 1)
		elseif (looter:getVehicle():vehicletypeid() == 205) then
			looter:inventory_modify("ECM Device", 1)
		elseif (looter:getVehicle():vehicletypeid() == 200) then
			looter:inventory_modify("ECM Device", 1)
		elseif (looter:getVehicle():vehicletypeid() == 203) then
			looter:inventory_modify("ECM Device", 1)
		elseif (looter:getVehicle():vehicletypeid() == 204) then
			looter:inventory_modify("ECM Device", 1)
		elseif (looter:getVehicle():vehicletypeid() == 202) then
			looter:inventory_modify("ECM Device", 1)
		elseif (looter:getVehicle():vehicletypeid() == 209) then
			looter:inventory_modify("ECM Device", 1)
		elseif (looter:getVehicle():vehicletypeid() == 210) then
			looter:inventory_modify("ECM Device", 1)
		elseif (looter:getVehicle():vehicletypeid() == 211) then
			looter:inventory_modify("ECM Device", 1)

		else
		end
		
	
	end
	return true
end

--function Arena_OnGameStart()
--end

--if (looter:crown() == false) then
--		looter:message("False")
--	elseif (looter:crown() == true) then
--		looter:message("True")
--	end