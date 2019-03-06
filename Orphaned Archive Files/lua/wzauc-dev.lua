--- [[ Global Variables ]] ----------
 
g_arena = nil		-- The global arena class, to avoid having to pass it around functions

-- Variables to control the baitbox
g_CashCrateVid = 422
g_CashCrateDropItemName = "Money $1000"

-- Variables to control the HQ
g_HqRewardTime = -120000				-- how often in ms will the HQ reward be rewarded and calculated
g_hqrewardep = 0						-- The eventid for the reward from headquarter vehicles
g_HqTable = {nil}						-- Table that keeps track of all the HQ in the game.  I believe I made it 1 based
g_HqTableSize = 0						-- the g_HqTable size.  It is used for keeping track of how many entries are in the table
g_HqRewardInitialAmount = 5				-- initial seed for the HQ reward
g_HqRewardExponent = 1					-- the exponent to raise the HQ reward to each time it is calculated
g_HqRewardMultiplier = 1.05				-- after raising to the exponent, the multiply this to the HQ reward to each time it is calculated
g_HqRewardAdd = 1						-- after all that, add this to the amount
g_HqRewardMax = 4000					-- maximum value for the HQ reward (not being used right now)
g_HqPointsMultiplier = 4				-- multiply the base reward by this for points
g_HqExpMultiplier = 3					-- multiply the base reward by this for experience
g_HqCashMultiplier = 13					-- multiply the base reward by this for cash
g_HqDestroyPointsMultiplier = 40		-- multiply this by the last reward to calculate the reward given to the team which destroyed the HQ
g_HqDestroyExpMultiplier = 30			-- multiply this by the last reward to calculate the reward given to the team which destroyed the HQ
g_HqDestroyCashMultiplier = 130			-- multiply this by the last reward to calculate the reward given to the team which destroyed the HQ
g_HqItemMaker = 171						-- the warp item which creates the HQ
g_HqItemMakerName = "Headquarters Kit"	-- the warp item's name (this was a work around since I can't modify inventory based on item number from the .itm file)
g_HqVid = 423							-- the HQ vehicle ID
g_HqMaxAllowed = 1						-- the maximum amount of HQ you are allowed to have.  Technically you have have more if you steal one with a control item
g_WarpToHqItem = 170
g_immortal = ""

g_ScriptNews = "Here is where I will put my news updates to the script"
g_StartCash = 0
g_StartExp = 0

g_Duelist1 = ""
g_Duelist2 = ""
g_Duelist3 = ""
g_Duelist4 = ""
g_Duelist5 = ""
g_Duelist6 = ""
g_TickerMessage1 = ""
g_TickerMessage2 = ""
g_TickerMessage3 = ""
g_TickerMessage4 = ""

dofile("utility.lua")

function Vehicle_OnProduce(producer, user, menuitem)
	if (producer:vehicletypeid() ~= 426) then
		return true
	else
		if (menuitem == 0) then
			if (g_Duelist1 ~= "") then
				user:message("&Dueling Station> Duelist 1 is already taken by " .. g_Duelist1)
			elseif (g_Duelist2 == user.m_name or g_Duelist3 == user.m_name or g_Duelist4 == user.m_name or g_Duelist5 == user.m_name or g_Duelist6 == user.m_name ) then
				user:message("&Dueling Station> You can not sign up twice")
			elseif (g_Duelist2 ~="") then
				local otherplayer = g_arena:getPlayer(g_Duelist2)
				g_Duelist1 = user.m_name
				SpecTeam("Duelist1")
				user:team_change("Duelist1","a90fp23asdf")
				user:warp(464,8560,0)
				SpecTeam("Duelist2")
				otherplayer:team_change("Duelist2","fjh879a4")
				otherplayer:warp(1392,8992,0)
			else
				g_Duelist1 = user.m_name
			end
		elseif (menuitem == 1) then
			if (g_Duelist2 ~= "") then
				user:message("&Dueling Station> Duelist 2 is already taken by " .. g_Duelist2)
			elseif (g_Duelist1 == user.m_name or g_Duelist3 == user.m_name or g_Duelist4 == user.m_name or g_Duelist5 == user.m_name or g_Duelist6 == user.m_name ) then
				user:message("&Dueling Station> You can not sign up twice")
			elseif (g_Duelist1 ~="") then
				local otherplayer = g_arena:getPlayer(g_Duelist1)
				g_Duelist2 = user.m_name
				SpecTeam("Duelist2")
				user:team_change("Duelist2","fjh879a4")
				user:warp(1392,8992,0)
				SpecTeam("Duelist1")
				otherplayer:team_change("Duelist1","a90fp23asdf")
				otherplayer:warp(464,8560,0)
			else
				g_Duelist2 = user.m_name
			end
		elseif (menuitem == 2) then
				user:message("Disabled")
			-- if (g_Duelist3 ~= "") then
				-- user:message("&Dueling Station> Duelist 3 is already taken by " .. g_Duelist3)
			-- elseif (g_Duelist1 == user.m_name or g_Duelist2 == user.m_name or g_Duelist4 == user.m_name or g_Duelist5 == user.m_name or g_Duelist6 == user.m_name ) then
				-- user:message("&Dueling Station> You can not sign up twice")
			-- elseif (g_Duelist4 ~="") then
				-- local otherplayer = g_arena:getPlayer(g_Duelist4)
				-- g_Duelist3 = user.m_name
				-- user:team_change("Duelist3","")
				-- user:warp(1392,10176,0)
				-- otherplayer:team_change("Duelist4","")
				-- otherplayer:warp(464,9744,0)
			-- else
				-- g_Duelist3 = user.m_name
			-- end
		elseif (menuitem == 3) then
				user:message("Disabled")
			-- if (g_Duelist4 ~= "") then
				-- user:message("&Dueling Station> Duelist 4 is already taken by " .. g_Duelist4)
			-- elseif (g_Duelist1 == user.m_name or g_Duelist2 == user.m_name or g_Duelist3 == user.m_name or g_Duelist5 == user.m_name or g_Duelist6 == user.m_name ) then
				-- user:message("&Dueling Station> You can not sign up twice")
			-- elseif (g_Duelist3 ~="") then
				-- local otherplayer = g_arena:getPlayer(g_Duelist3)
				-- g_Duelist2 = user.m_name
				-- user:team_change("Duelist4","")
				-- user:warp(1392,10176,0)
				-- otherplayer:team_change("Duelist3","")
				-- otherplayer:warp(464,9744,0)
			-- else
				-- g_Duelist4 = user.m_name
			-- end
		elseif (menuitem == 4) then
				user:message("Disabled")
			-- if (g_Duelist5 ~= "") then
				-- user:message("&Dueling Station> Duelist 5 is already taken by " .. g_Duelist5)
			-- elseif (g_Duelist1 == user.m_name or g_Duelist2 == user.m_name or g_Duelist3 == user.m_name or g_Duelist4 == user.m_name or g_Duelist6 == user.m_name ) then
				-- user:message("&Dueling Station> You can not sign up twice")
			-- elseif (g_Duelist6 ~="") then
				-- local otherplayer = g_arena:getPlayer(g_Duelist6)
				-- g_Duelist1 = user.m_name
				-- user:team_change("Duelist5","")
				-- user:warp(1856,8560,0)
				-- otherplayer:team_change("Duelist6","")
				-- otherplayer:warp(2800,8992,0)
			-- else
				-- g_Duelist5 = user.m_name
			-- end
		elseif (menuitem == 5) then
				user:message("Disabled")
			-- if (g_Duelist6 ~= "") then
				-- user:message("&Dueling Station> Duelist 6 is already taken by " .. g_Duelist6)
			-- elseif (g_Duelist1 == user.m_name or g_Duelist2 == user.m_name or g_Duelist3 == user.m_name or g_Duelist4 == user.m_name or g_Duelist5 == user.m_name ) then
				-- user:message("&Dueling Station> You can not sign up twice")
			-- elseif (g_Duelist5 ~="") then
				-- local otherplayer = g_arena:getPlayer(g_Duelist5)
				-- g_Duelist6 = user.m_name
				-- user:team_change("Duelist6","")
				-- user:warp(2800,8992,0)
				-- otherplayer:team_change("Duelist5","")
				-- otherplayer:warp(1856,8560,0)
			-- else
				-- g_Duelist6 = user.m_name
			-- end
		else
			user:message("&Dueling Station>You can only choose menu 1, 2, 3, 4, 5, or 6")
		end
		return false
	end
end

function airstrike(player)
	local pos = player:coords()
	local j = 0
	for i=0,400,80 do
		j = j + 200
		local argtable = {}
		argtable[1] = GetCoordsInFront(pos, 100) 
		argtable[2] = player:frequency()
		event_createarg(airstrikedelaywrapper, j, g_arena, argtable)
	end
end

function airstrikedelaywrapper(vTable)
	return airstrikedelay(vTable[1], vTable[2])
end

function airstrikedelay(coord,freq)
		g_arena:explosion_create("Airstrike Missle", coord.x, coord.y, coord.rotation, freq)
		return true
end

function shotgun(explosion,x,y,rot,freq)
	for i=0,60,3 do
		local r = rot-i
		if (r<0) then
			r = r+240
		end
		g_arena:explosion_create(explosion,x,y,r,freq)
	end
	return false
end

function SpecTeam(teamname)
	local team = team_fromname(g_arena, teamname)
	if (team:exists()) then
		for i = 1, team:num() do
			local player = team:get(i)
			player:team_change("spec","")
			player:setVehicle(0) -- force the spec vehicle
		end
	end
end

function RandomBounty(prizetype)
	prizetype = tonumber(prizetype)
	if (prizetype == 1) then
		local player = randomplayer()
		giveabsbounty(player.m_name, 1000)
		g_arena:message(player.m_name .. " has just been randomly awarded 1,000 bounty")
	elseif (prizetype == 2) then
		local player = randomplayer()
		giveabsbounty(player.m_name, 5000)
		g_arena:message(player.m_name .. " has just been randomly awarded 5,000 bounty")
	elseif (prizetype == 3) then
		local player = randomplayer()
		giveabsbounty(player.m_name, 10000)
		g_arena:message(player.m_name .. " has just been randomly awarded 10,000 bounty")
	elseif (prizetype == 4) then
		local player = randomplayer()
		giveabsbounty(player.m_name, 30000)
		g_arena:message(player.m_name .. " has just been randomly awarded 30,000 bounty")
	end
end

function RandomPrize(prize)
	local player = randomplayer()
	player:inventory_modify(prize, 1)
	g_arena:message(player.m_name .. " was randomly awarded a " .. prize)
end

function Player_OnJoin(player)
	player:setticker(1, g_TickerMessage1)
	player:setticker(2, g_TickerMessage2)
	player:setticker(3, g_TickerMessage3)
	player:setticker(4, g_TickerMessage4)
	-- if (string.lower(g_arena.mname) == "ovd") then
		-- g_arena:message("Eventually this arena will be scripted")
	-- end
--	player:modcash(g_StartCash)
--	player:modexperience(g_StartExp)
end

function Player_OnDeath(killer, victim)
	local victimname = string.lower(victim.m_name)
	if (victimname == g_immortal) then
		victim:resurrect()
	end
	if (victimname == string.lower(g_Duelist1) or victimname == string.lower(g_Duelist2)) then
		local Duelist1 = g_arena:getPlayer(g_Duelist1)
		local Duelist2 = g_arena:getPlayer(g_Duelist2)
		if (Duelist1:valid()) then
			Duelist1:warp(928,9216,0)
			Duelist1:team_change("AfterDuel","kjdhga043")
		end	
		if (Duelist2:valid()) then
			Duelist2:warp(928,9216,0)
			Duelist2:team_change("AfterDuel","kjdhga043")
		end
		g_Duelist1 = ""
		g_Duelist2 = ""
	-- elseif (victimname == string.lower(g_Duelist3) or victimname == string.lower(g_Duelist4)) then
		-- local Duelist3 = g_arena:getPlayer(g_Duelist3)
		-- local Duelist4 = g_arena:getPlayer(g_Duelist4)
		-- if (Duelist3:valid()) then
			-- Duelist3:warp(928,9216,0)
			-- Duelist3:team_change("AfterDuel","kjdhga043")
		-- end	
		-- if (Duelist4:valid()) then
			-- Duelist4:warp(928,9216,0)
			-- Duelist4:team_change("AfterDuel","kjdhga043")
		-- end
		-- g_Duelist3 = ""
		-- g_Duelist4 = ""
	-- elseif (victimname == string.lower(g_Duelist5) or victimname == string.lower(g_Duelist6)) then
		-- local Duelist5 = g_arena:getPlayer(g_Duelist5)
		-- local Duelist6 = g_arena:getPlayer(g_Duelist6)
		-- if (Duelist5:valid()) then
			-- Duelist5:warp(928,9216,0)
			-- Duelist5:team_change("AfterDuel","kjdhga043")
		-- end	
		-- if (Duelist6:valid()) then
			-- Duelist6:warp(928,9216,0)
			-- Duelist6:team_change("AfterDuel","kjdhga043")
		-- end
		-- g_Duelist5 = ""
		-- g_Duelist6 = ""
	end
	victim:inventory_modify("Energy Cells", 600)
	if (killer:exists()) then 
		UpdateKillTracker(killer)
	end
end 

function UpdateKillTracker(killer)
	local teamfreq = killer:frequency()
	for x = 1, g_HqTableSize do
		local HQ = g_HqTable[x]
		if (HQ:frequency() == teamfreq and HQ:health() ~= 0) then
			HQ:setvarint("kills", HQ:getvarint("kills") + 1)
		end
	end
end

function xwrapper(vTable)
	return x(vTable[1], vTable[2], vTable[3], vTable[4], vTable[5])
end

function x(a, b, c, d, e)

end

function y(a,b,c,d,e)

end

function z(a,b,c,d,e)

end

function ic(a,b,c)
	local pos = a:coords()
	g_arena:item_create(b, c, pos.x, pos.y)
end

function ec(a,b,c,d) 
	g_arena:explosion_create(a,b,c,d,0)
	return false
end

function ticker1(msg)
	local numteam = g_arena:numteam()
	g_TickerMessage1 = msg
	for i = 1, numteam do
		local TheTeam =	g_arena:getteam(i)
		for i = 1, TheTeam:num() do
			local player = TheTeam:get(i)
			player:setticker(1, msg)
		end
	end
end

function ticker2(msg)
	local numteam = g_arena:numteam()
	g_TickerMessage2 = msg
	for i = 1, numteam do
		local TheTeam =	g_arena:getteam(i)
		for i = 1, TheTeam:num() do
			local player = TheTeam:get(i)
			player:setticker(2, msg)
		end
	end
end

function ticker3(msg)
	local numteam = g_arena:numteam()
	g_TickerMessage3 = msg
	for i = 1, numteam do
		local TheTeam =	g_arena:getteam(i)
		for i = 1, TheTeam:num() do
			local player = TheTeam:get(i)
			player:setticker(3, msg)
		end
	end
end

function ticker4(msg)
	local numteam = g_arena:numteam()
	g_TickerMessage4 = msg
	for i = 1, numteam do
		local TheTeam =	g_arena:getteam(i)
		for i = 1, TheTeam:num() do
			local player = TheTeam:get(i)
			player:setticker(4, msg)
		end
	end
end

-- This runs when a player types a ? command such as ?mynewcommand
-- Yes, this is totally unsecure.  I will add some code later to look up allowed users in a file or something.
function Msg_OnCommand(player, command, payload, recipient, msg_type)
	cmd = string.lower(command)
	if (cmd == "?effect") then
		HqDropEffect(player:coords(), player:frequency())
	elseif(cmd == "?create") then
		CreateHq(player:coords(), player:frequency())
	elseif(cmd == "?scriptnews") then
		player:message(g_ScriptNews)
	elseif(cmd == "?x") then
		x(player, command, payload, recipient, msg_type)
	elseif(cmd == "?y") then
		y(player, command, payload, recipient, msg_type)
	elseif(cmd == "?z") then
		z(player, command, payload, recipient, msg_type)
	elseif(cmd == "?ticker") then
		ticker1(payload)
	elseif(cmd == "?ticker2") then
		ticker2(payload)
	elseif(cmd == "?ticker3") then
		ticker3(payload)
	elseif(cmd == "?ticker4") then
		ticker4(payload)
	elseif(cmd == "?randombounty") then
		RandomBounty(payload)
	elseif(cmd == "?randomprize") then
		RandomPrize(payload)
	elseif(cmd == "?ic") then
		ic(player, payload, 1)
	elseif(cmd == "?cannon") then
		local c1 = player:coords()
		g_arena:message(player.m_name .. " has fired the Orbital Ion Cannon")
		g_arena:explosion_create("Orbital Ion Cannon", c1.x,c1.y,c1.rotation,player:frequency())
	elseif(cmd == "?ec") then
		local c1 = player:coords()
		g_arena:explosion_create(payload, c1.x,c1.y,c1.rotation,player:frequency())
	elseif(cmd == "?reward") then
		DisplayHqReward(player)
	elseif(cmd == "?restarthq") then
		payload = tonumber(payload)
		local HQ = g_HqTable[payload]
		HQ:setvarint("ep", event_createarg(RewardHqTeamWrapper, g_HqRewardTime, g_arena, {HQ}))
	elseif(cmd == "?createvehicle") then
		local pos = player:coords()
		local vec = tonumber(payload)
		local veh = g_arena:vehicle_create(vec, pos.x, pos.y, pos.rotation)
		veh:setfrequency(player:frequency())
	elseif(cmd == "?immortal") then
		g_immortal = string.lower(payload)
	elseif(cmd == "?staffspec") then
		player:setVehicle(41)
	elseif(cmd == "?showtable") then
		showtable(payload)
	--elseif(cmd == "?testwarp") then
	--	ParachuteWarp(player, player:coords())
	elseif(cmd == "?par") then
		ParachuteWarp(player, player:coords())
	elseif(cmd == "?givebounty") then
		givebounty(player.m_name, payload)
	elseif(cmd == "?30k") then
		if(giveabsbounty(payload, 30000) == false) then
			player:message("Unable to give the player 30K bounty.  Most likely you typed the name wrong or the player is in spec")
		end
	elseif(cmd == "?coord" or cmd == "?coords" ) then
		local pos = player:coords()
		player:message("Your coordinates are x= " .. pos.x .. ", y= " .. pos.y .. ", z= " .. pos.z .. ", rotation= " ..pos.rotation)
	elseif(cmd == "?testdummy") then
		local theplayer = g_arena:getPlayer(payload)
		if (theplayer:valid() and not theplayer:spectator() ) then
			theplayer:setVehicle(131)
			return true
		else
		return false
		end	
	elseif(cmd == "?untestdummy") then
		local theplayer = g_arena:getPlayer(payload)
		if (theplayer:valid() and not theplayer:spectator() ) then
			theplayer:setVehicle(1)
			return true
		else
		return false
		end	
	elseif(cmd == "?stas") then
		player:message("STAS is so cool")
	elseif(cmd == "?show") then
		ShowRewards(player)
	elseif(cmd == "?hq") then
		ShowRewards(player)
	end
end

function DisplayHqReward(player)
	local HqCount = 0
	for i = 1, g_HqTableSize do
		local HqCheck = g_HqTable[i]
		if (HqCheck:frequency() == player:frequency() and HqCheck:health() ~= 0) then
			HqCount = HqCount+1
			local TheTeam = team_fromid(g_arena, player:frequency())
			if (TheTeam:exists()) then
				local numPlaying = TheTeam:numplaying()
				if (numPlaying == 0) then
					numPlaying = 1
				end
				local basereward = math.ceil(HqCheck:getvarint("kills") / numPlaying)
				player:message("&Headquarters> If the reward was calculated right now, you would receieve " .. (basereward * g_HqPointsMultiplier) .. " points " .. (basereward * g_HqExpMultiplier).. " experience and " .. (basereward * g_HqCashMultiplier) .. " cash.")
			end
		end
	end
	if (HqCount == 0) then
		player:message("&Headquarters> Your team does not have a headquarters")
	end
end
-- Runs when the arena is created
function Arena_OnCreate(arena)
	g_arena = arena

	-- Install the event procedure to calculate the reward and award people for having an HQ
       -- g_hqrewardep = event_create(RewardHq, g_HqRewardTime, arena)

end

-- Runs when a player uses a warp item
function Player_OnWarpItem(user, itemid, target)

	--g_arena:message("Player_OnWarpItem ran with itemid = " .. itemid)

	-- check to see if the warp item was the item used to create an HQ
	if (HqItemMaker(user, itemid, target)) then
		return false
	elseif (itemid == g_WarpToHqItem) then
			WarpToHQ(user)
			return false
	elseif (itemid == 225) then
		airstrike(user)
	else
		return true
	end
end

-- Why does this crash my server?!?
function Vehicle_OnCreate(vehicle)
--	print("Vehicle_OnCreate ran")
	--g_arena:message("Vehicle_OnCreate ran")
end

-- Runs when a computer vehicle is destroyed
function Vehicle_OnDeath(victim,killer)

	-- If it is a baitbox, do this
	CheckCashCrateDeath(victim,killer)

	-- if it is an headquarters, do this
	CheckHqDeath(victim,killer)

	return true
end

-- place a call to this function in the Vehicle_OnDeath event.
-- This function checks to see if a headquarters item maker was launched
-- The headquarters item maker is nothing but a warp item in the .itm file
function HqItemMaker(user, itemid, target)
	-- add code so there is a limit to the number of HQ
	if (itemid == g_HqItemMaker) then
		-- First loop through all the HQ and see if this team already possess one
		for i = 1, g_HqTableSize do
			local HqCheck = g_HqTable[i]
			if (HqCheck:frequency() == user:frequency() and HqCheck:health() ~= 0) then
				user:message("&Headquarters> Your team already has the maximum amount of headquarters in their possesion")
				-- Give the guy his kit back
				user:inventory_modify("Headquarters Kit", 1)
				return false
			end
		end
		local HqCount = g_HqTableSize + 1
		local numPlaying = g_arena:numplaying()

		--g_arena:message("numPlaying = " .. numPlaying .. " HqCount = " .. HqCount .. " the math comes to " .. math.floor(numPlaying/HqCount))

		-- this limits the number of HQ in the game dynamicly
		if (math.floor(numPlaying/20) >= HqCount or numPlaying < 40) then
			--HqDropEffect(user:coords(), user:frequency())
			CreateHq(user:coords(), user:frequency())
		else
			user:message("&Headquarters> The arena already has the maximum amount of headquarters")
			user:inventory_modify("Headquarters Kit", 1)
			return false
		end


		return true
	else
		return false
	end
end

-- This function adds a drop effect before creating the HQ
function HqDropEffect(pos, freq)
--	g_arena:explosion_create("Headquarters Drop Effect", pos.x, pos.y , pos.rotation, 0)
	g_arena:explosion_create("Child - Headquarters Drop", pos.x, pos.y , pos.rotation, 0)
	g_arena:explosion_create("Child - Vehicle Drop Chute Lg", pos.x, pos.y , pos.rotation, 0)
	HqDropEp = event_createarg(CreateHqWrapper, 2000, g_arena, {pos, freq})
end

-- This was created because the event_createarg function wasn't passing the arguments in the correct way
function CreateHqWrapper(vtable)
	CreateHq(vtable[1], vtable[2])
	return false
end

-- Function to create an HQ
function CreateHq(pos, freq)
		local HQ = g_arena:vehicle_create(g_HqVid, pos.x, pos.y, pos.rotation)
		HQ:setfrequency(freq)

		-- store the initial reward
		HQ:setvarint("reward", g_HqRewardInitialAmount)
		HQ:setvar("team", teamnamefromfreq(HQ:frequency()))
		HQ:setvarint("ep", event_createarg(RewardHqTeamWrapper, g_HqRewardTime, g_arena, {HQ}))
		HQ:setvarint("kills", 0)
		AddToHqTable(HQ)
		MessageTeam(freq, "&Headquarters> A new headquarters has been created for your team")
end

function AddToHqTable(HQ)
		g_HqTableSize = g_HqTableSize + 1
		g_HqTable[g_HqTableSize] = HQ
end

function DelFromHqTable(HQ)
	local i = 0
	while i < g_HqTableSize do
		i = i + 1
		local xHQ = g_HqTable[i]
		if (HQ:vehicleid() == xHQ:vehicleid()) then
			g_HqTable = table_remove(g_HqTable, i, g_HqTableSize)
			g_HqTableSize = g_HqTableSize - 1
			i = 0
		end
	end
end

function table_remove(t, index, tLen)
	for i  = index, tLen do
		if (i ~= tLen) then
			t[i] = t[i+1]
		else
			t[i] = nil
		end
	end
	return t
end

function showtable(payload)
		local x = g_HqTableSize
		if (payload ~= nil and payload ~= "") then
			x = tonumber(payload)
		end
		for i = 1, x do
			if (g_HqTable[i] == nil) then
				g_arena:message("element " .. i .. " was nil")
			else
				g_arena:message("team " .. teamnamefromfreq(g_HqTable[i]:frequency()) .. " | " .. g_HqTable[i]:getvar("team") .. " vehicleid " .. g_HqTable[i]:vehicleid())
			end
		end

end

function ShowRewards(player)
		local x = g_HqTableSize
		if (payload ~= nil and payload ~= "") then
			x = tonumber(payload)
		end
		player:message("Current defense reward multipliers: Points " .. g_HqPointsMultiplier .. ", experience " .. g_HqExpMultiplier .. ", cash " .. g_HqCashMultiplier)
		player:message("Current attack reward multipliers: Points " .. g_HqDestroyPointsMultiplier .. ", experience " .. g_HqDestroyExpMultiplier .. ", cash " .. g_HqDestroyCashMultiplier)
		--player:message("Your current reward is " .. (kills * g_HqPointsMultiplier) .. " points " .. (kills * g_HqExpMultiplier).. " experience and " .. (kills * g_HqCashMultiplier) .. " cash which is based on " .. kills .. " kills")
		for i = 1, x do
			if (g_HqTable[i] == nil) then
				player:message("element " .. i .. " was nil")
			else
				local HQ = g_HqTable[i]
				local basereward = HQ:getvarint("reward")
				local kills = HQ:getvarint("kills")
				--player:message("team " .. teamnamefromfreq(g_HqTable[i]:frequency()) .. " has a reward of " .. (basereward * g_HqPointsMultiplier) .. " points " .. (basereward * g_HqExpMultiplier) .. " experience and " .. (basereward * g_HqCashMultiplier) .. " cash.")
				--player:message("kill based rewards will be " .. teamnamefromfreq(g_HqTable[i]:frequency()) .. " has a reward of " .. (kills * g_HqPointsMultiplier) .. " points " .. (kills * g_HqExpMultiplier) .. " experience and " .. (kills * g_HqCashMultiplier) .. " cash.")
				player:message("Team " .. teamnamefromfreq(g_HqTable[i]:frequency()) .. " has a base reward of " .. kills)
			end
		end

end

-- this darn function is so SLOPPY and it isn't working.  I found a different way
function RemoveOrphanHq()
			g_arena:message("RemoveOrphanHq() start ----------")
	-- local i = 1
	-- while i <= g_HqTableSize do
		-- g_arena:message("Begin loop.  i= " .. i .. "  g_HqTableSize = " .. g_HqTableSize)
		-- showtable()
		-- local HQ = g_HqTable[i]
		-- if (HQ ~= nil) then
			-- g_arena:message("vehicleid = " .. HQ:vehicleid())
			-- local TheTeam = oteam_fromfreq(g_arena, HQ:frequency())
			-- if (TheTeam:exists() == false) then
				--destroy the HQ and remove it from the table
				--I should add some kind of neat effect when this happens
				-- g_arena:message("removing " .. i .. " vehicleid = " .. HQ:vehicleid()  .. " team = " .. HQ:getvar("team"))
				-- HQ:destroy()
				-- table.remove(g_HqTable, i)
				-- g_HqTableSize = g_HqTableSize - 1
				--reset the loop and start at the begining
				-- i = 1
			-- else
				-- g_arena:message("incrementing " .. i)
				-- i = i + 1
			-- end
		-- else
			-- i = i + 1
		-- end
	-- end
	-- if (g_HqTable ~= nil and g_HqTableSize ~= 0) then
		-- for i = 1, g_HqTableSize do 
			-- g_arena:message("RemoveOrphanHq() loop start ----------")
			-- showtable()
			-- local value = g_HqTable[i]
			-- if (value ~= null) then
				-- if (teamnamefromfreq(value:frequency()) == "Non-existant team") then
					-- DelFromHqTable(value)
--					table_remove(g_HqTable, index)
--					g_HqTableSize = g_HqTableSize - 1
					-- value:destroy()
				-- end
			-- end		
		-- end
	-- end

end


function RewardHqTeamWrapper(vTable)
	return RewardHqTeam(vTable[1])
end

function RewardHqTeam(HQ)
		if (HQ:frequency() == nil) then
			g_arena:message("HQ returned nil")
			return true
		end
		--local TheTeam = oteam_fromfreq(g_arena, HQ:frequency())
		local TheTeam = team_fromid(g_arena, HQ:frequency())
		if (TheTeam:exists()) then
			-- enum all the members
			local numMembers = TheTeam:num()
			local numPlaying = TheTeam:numplaying()
			if (numPlaying == 0) then
				numpPlaying = 1
			end
			local basereward = math.ceil(HQ:getvarint("kills") / numPlaying)

			for i = 1, numMembers do
				local member = TheTeam:get(i)

				if (member:spectator()) then 
					member:message("&Headquarters> You missed out on the team reward of " .. (basereward * g_HqPointsMultiplier) .. " points " .. (basereward * g_HqExpMultiplier) .. " experience and " .. (basereward * g_HqCashMultiplier) .. " cash because you are in spec.")
				elseif (member:valid()) then
					member:modpoints(basereward * g_HqPointsMultiplier)
					member:modexperience(basereward * g_HqExpMultiplier)
					member:modcash(basereward * g_HqCashMultiplier)
					member:message("&Headquarters> For defending your headquarters you have receieved " .. (basereward * g_HqPointsMultiplier) .. " points " .. (basereward * g_HqExpMultiplier).. " experience and " .. (basereward * g_HqCashMultiplier) .. " cash.")
				end
			end
					
			-- calculate the next reward
			basereward = HqCalcReward(basereward, g_HqRewardExponent, g_HqRewardMultiplier, g_HqRewardAdd)
			HQ:setvarint("reward", basereward)
		else
			DelFromHqTable(HQ)
			if (HQ ~= nil) then
				HQ:destroy()
			end
			return true
		end
		return false
end


-- The event procedure which runs and rewards people for having headquarters
-- add this line to the function Arena_OnCreate(arena)
-- g_hqrewardep = event_create(RewardHq, g_HqRewardTime, arena)
-- function RewardHq()
	-- if (q_HqTableSize == 0) then
		-- return false
	-- end

	-- RemoveOrphanHq()
	-- g_arena:message("RewardHQ g_HqTableSize = " .. g_HqTableSize)
	
	-- for x = 1, g_HqTableSize do
		-- local HQ = g_HqTable[x]
		-- RewardHqTeam(HQ)
	-- end


	-- return false
-- end

-- This is for the Warp to HQ item.  It will warp a person to their HQ.  Right now, if they have more than one HQ, it choses one at random.
function WarpToHQ(user)
	local teamfreq = user:frequency()
	local teamHQ = {}
	local teamHQsize = 0
	for x = 1, g_HqTableSize do
		local HQ = g_HqTable[x]
		if (HQ:frequency() == teamfreq and HQ:health() ~= 0) then
			table.insert(teamHQ, HQ)
			teamHQsize = teamHQsize + 1
		end
	end

	if (teamHQsize == 0) then
		user:message("&Headquarters> Your team does not have a headquarters you can warp to")
		user:inventory_modify("Energy Cells", 300)
		return false
	else
		local rNum = math.random(1, teamHQsize)
		local HQ = teamHQ[rNum]
		local pos = HQ:coords()
		--ParachuteWarp(user, pos)
		user:warp(pos.x, pos.y, 0)
		return true
	end
end

function MessageTeam(frequency, message)
	local TheTeam = oteam_fromfreq(g_arena, frequency)
	if (TheTeam:exists()) then
		local numMembers = TheTeam:num()
		for i = 1, numMembers do
			local member = TheTeam:get(i)
			if member:valid() then
				member:message(message)
			end
		end
	end

end

-- Why do I have two message team fuctions?
function MsgTeam(oTeam, message)
	if (oTeam:exists()) then
		local numMembers = oTeam:num()
		for i = 1, numMembers do
			local member = oTeam:get(i)
			if member:valid() then
					member:message(message)
			end
		end
	end
end

-- place a call to this function in the Vehicle_OnDeath event.
-- This function checks to see if the headquarters vehicle was the one that was destroyed
-- then does the rewards and such
function CheckHqDeath(victim, killer)
	local vid = victim:vehicletypeid()


	if (vid == g_HqVid) then
		local HqOwnedBy = teamnamefromfreq(victim:frequency())
		--local TheReward = victim:getvarint("reward")

		-- Add code so you don't get a reward if you blow up your own HQ
		if (killer:frequency() == victim:frequency()) then
			local TheReward = victim:getvarint("kills")
			local RewardPoints = TheReward * g_HqDestroyPointsMultiplier * -1
			local RewardExp = TheReward * g_HqDestroyExpMultiplier * -1
			local RewardCash = TheReward * g_HqDestroyCashMultiplier * -1
			killer:modpoints(RewardPoints)
			killer:modexperience(RewardExp)
			killer:modcash(RewardCash)
			-- killer:message("&Headquarters> You have lost " .. RewardPoints .. " points, " .. RewardExp .. " experience, and " .. RewardCash .. " cash for destroying your own headquarters")
			-- message the team and tell them who the idiot was
			-- local TheTeam = team_fromname(g_arena, killer:getTeam().m_name)
			-- if (TheTeam:exists()) then

				--enum all the members
				-- local numMembers = TheTeam:num()

				-- for i = 1, numMembers do
					-- local member = TheTeam:get(i)
					-- if member:valid() then
--						g_arena:message("&Headquarters> Team " .. teamnamefromfreq(victim:frequency()) .. "'s headquarters was destroyed by their teammate, " .. killer.m_name .. ".  " .. killer.m_name .. " lost " .. RewardPoints .. " points, " .. RewardExp .. " experience, and " .. RewardCash .. " cash")
						g_arena:message("&Headquarters> Team " .. HqOwnedBy .. "'s headquarters was destroyed by their teammate, " .. killer.m_name .. ".  " .. killer.m_name .. " was penalized " .. RewardPoints .. " points, " .. RewardExp .. " experience, and " .. RewardCash .. " cash")
					-- end
				-- end
			-- end
		else
			
			--reward the team which killed the HQ
			local TheTeam = team_fromname(g_arena, killer:getTeam().m_name)
			if (TheTeam:exists()) then

				-- enum all the members
				local numMembers = TheTeam:num()
				local numPlaying = TheTeam:numplaying()

				-- I need to fix this part later
				local TheReward = math.ceil(victim:getvarint("kills") / numPlaying)
				local Bounty = math.ceil(victim:getvarint("kills") / 6)
				if (Bounty>30000) then 
					Bounty = 30000
				end

				local RewardPoints = TheReward * g_HqDestroyPointsMultiplier
				local RewardExp = TheReward * g_HqDestroyExpMultiplier
				local RewardCash = TheReward * g_HqDestroyCashMultiplier

				for i = 1, numMembers do
					local member = TheTeam:get(i)
					if member:valid() then
						if (member:spectator()) then 
							member:message("&Headquarters> You missed out on the reward of " .. RewardPoints .. " points, " .. RewardExp .. " experience, and " .. RewardCash .. " cash because you are in spec.")
						else
							member:modpoints(RewardPoints)
							member:modexperience(RewardExp)
							member:modcash(RewardCash)
							--member:message("&Headquarters> " .. killer.m_name .. " has finished off " .. HqOwnedBy .. "'s headquarters.  Your team has been rewarded " .. RewardPoints.. " points, " .. RewardExp .. " experience, and " .. RewardCash .. " cash.")
							givebounty(member.m_name, Bounty)
							member:inventory_modify("Flag Grenade", 2)
						end
					end
				end
				-- Add the kills from the dead HQ to the team's HQ if they have one
				AddHqBonus(killer:frequency(), victim:getvarint("kills"))
				-- Tell the arena an HQ was destroyed
				g_arena:message("&Headquarters> " .. killer.m_name .. " of team " .. killer:getTeam().m_name .. " has destroyed " .. HqOwnedBy .. "'s headquarters. Team " .. killer:getTeam().m_name .. " has been rewarded " .. RewardPoints.. " points, " .. RewardExp .. " experience, and " .. RewardCash .. " cash.")
			end
		end

		event_destroy(victim:getvarint("ep"))
		DelFromHqTable(victim)

	end

end

function AddHqBonus(teamfreq, bonus)
	for x = 1, g_HqTableSize do
		local HQ = g_HqTable[x]
		if (HQ:frequency() == teamfreq and HQ:health() ~= 0) then
				MsgTeam(oteam_fromfreq(g_arena, teamfreq), "&Headquarters> A bonus base reward of " .. bonus .. " has been added to your headquarters")
				HQ:setvarint("kills", HQ:getvarint("kills") + bonus)
		end
	end	
end

-- function to calulate the HQ reward
function HqCalcReward(seed, power, multiplier, addition)
	local Reward = math.ceil((math.pow(seed, power) * multiplier) + addition)
	if (Reward > g_HqRewardMax) then
		Reward = g_HqRewardMax
	end
	return Reward
end

-- Sigh, this won't work since there is no z position I can warp the guy too.  I'll think of another way I guess.
function ParachuteWarp(player, pos)
	if (player:spectator() == false and player:valid()) then
		local xPos = player:coords()
		local v = g_arena:vehicle_create(133, xPos.x, xPos.y, 0)
		player:enterVehicle(v:vehicleid())
		v:move(pos.x, pos.y, 400, pos.rotation)
		g_arena:explosion_create("Child - Paradrop Effect", pos.x, pos.y , pos.rotation, 0)
	end
end

-- place a call to this function in the Vehicle_OnDeath event.
-- This function checks to see if a batibox was destroyed and then drops money
-- I need to add checks to see if the item will be dropped inside of physics.  If the item drops there
-- it disappears.  I think I would also like to make the distance slightly random but all in good time
function CheckCashCrateDeath(victim, killer)
	local vid = victim:vehicletypeid()

	-- If it is a baitbox, do this
	if (vid == g_CashCrateVid) then
		local pos = victim:coords()
		local pixeloffset = 70
		g_arena:item_create(g_CashCrateDropItemName, 1, pos.x, pos.y)
		g_arena:item_create(g_CashCrateDropItemName, 1, pos.x+pixeloffset, pos.y)
		g_arena:item_create(g_CashCrateDropItemName, 1, pos.x-pixeloffset, pos.y)
		g_arena:item_create(g_CashCrateDropItemName, 1, pos.x, pos.y+pixeloffset)
		g_arena:item_create(g_CashCrateDropItemName, 1, pos.x, pos.y-pixeloffset)
		g_arena:item_create(g_CashCrateDropItemName, 1, pos.x+pixeloffset, pos.y+pixeloffset)
		g_arena:item_create(g_CashCrateDropItemName, 1, pos.x+pixeloffset, pos.y-pixeloffset)
		g_arena:item_create(g_CashCrateDropItemName, 1, pos.x-pixeloffset, pos.y+pixeloffset)
		g_arena:item_create(g_CashCrateDropItemName, 1, pos.x-pixeloffset, pos.y-pixeloffset)
	end
end

-- This function appears to be moot since there was an undocumented fuction team_fromname(arena, string) I discovered in rox' ZZ script
-- This function doesn't even work how it is supposed to now that rox showed me what the return value was from the team_getid() fuction
-- Sigh, the team_getid() function only returns the value 4294967295 which demoship says is -1.  Just plain wierd
-- Ok, rox added a function team_fromID.  I'll play with this later.
function GetTeamIdByName(teamname)
	-- Return the team id for a team by name.  If the team doesn't exist, return 0 which is a team that doesn't exist
        local numteams = g_arena:numteam()
        for i = 1,  numteams do
		local xteam = g_arena:getteam(i)
 		if (xteam.m_name == teamname) then
			return i 
                end
        end
	return 0 

end

-- This function returns a team object based on a frequency.  It had to be written since there was no native way to get
-- a team object based on its frequency
function oteam_fromfreq(l_arena, teamfreq)
	-- make sure that teamfreq is in number format
	teamfreq = tonumber(teamfreq)
	
	return team_fromid(g_arena, teamfreq)
--        Cycle through the teams
        -- local numteams = g_arena:numteam()

--	teamids are 1 based
        -- for i = 1, numteams do
--		   Get team structure
			-- local cteam = g_arena:getteam(i)
			-- if (cteam:exists()) then
--				since there is no team:frequency() method at the time of this writting of this script
--				we have to grab the first player and find his frequency
				-- print("getting first player")
				-- local firstplayer = cteam:get(1)
				-- print("after get")
				-- if (firstplayer:frequency() == teamfreq) then
					-- return cteam
				-- end
			-- end
		-- end

--	not sure what I should return if the team wasn't found, so return a team that doesn't exist
	-- return team_fromname(l_arena, "somenamenoonewi11us3")
	
end

function teamnamefromfreq(freq)
	local myteam = oteam_fromfreq(g_arena, freq)
	if (myteam:exists()) then
		return myteam.m_name
	else
		return "Non-existant team"
	end

end

-- Sigh, this doesn't work on all servers
function givebounty(playername, bounty)
	local theplayer = g_arena:getPlayer(playername)
	if (theplayer:valid() and not theplayer:spectator() ) then
		theplayer:message("&Autobounty> Adding " .. bounty .. " bounty to your current bounty.  This will not display on your screen until your next kill.")
		theplayer:setbounty(false, tonumber(bounty))
		return true
	else
		return false
	end
end

-- Sigh, this doesn't work on all servers.  If it does, the player does not see that his bounty has risen until after his first kill.
function giveabsbounty(playername, bounty)
	local theplayer = g_arena:getPlayer(playername)
	if (theplayer:valid() and not theplayer:spectator() ) then
		theplayer:message("&Autobounty> Setting your bounty at " .. bounty .. ".  This will not display on your screen until your next kill.")
		theplayer:setbounty(true, tonumber(bounty))
		return true
	else
		return false
	end
end

