-- Variables to control the HQ
g_HqTable = {nil}						-- Table that keeps track of all the HQ in the game.  I believe I made it 1 based
g_HqTableSize = 0						-- the g_HqTable size.  It is used for keeping track of how many entries are in the table
g_HqItemMaker = 999						-- the warp item which creates the HQ
g_HqItemMakerName = "Build Base Control"			-- the warp item's name (this was a work around since I can't modify inventory based on item number from the .itm file)
g_HqVid = 999							-- the HQ vehicle ID
g_HqMaxAllowed = 1						-- the maximum amount of HQ you are allowed to have.  Technically you have have more if you steal one with a control item
g_WarpToHqItem = 555



-- Runs when a player uses a warp item
function Player_OnWarpItem(user, itemid, target)

	--g_arena:message("Player_OnWarpItem ran with itemid = " .. itemid)

	-- check to see if the warp item was the item used to create an HQ
	if (HqItemMaker(user, itemid, target)) then
		return false
	elseif (itemid == g_WarpToHqItem) then
			WarpToHQ(user)
			return false
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


-- This was created because the event_createarg function wasn't passing the arguments in the correct way
function CreateHqWrapper(vtable)
	CreateHq(vtable[1], vtable[2])
	return false
end

-- Function to create an HQ
function CreateHq(pos, freq)
		local HQ = g_arena:vehicle_create(g_HqVid, pos.x, pos.y, pos.rotation)
		HQ:setfrequency(freq)

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
		return false
	else
		local rNum = math.random(1, teamHQsize)
		local HQ = teamHQ[rNum]
		local pos = HQ:coords()
		user:warp(pos.x, pos.y, 0)
		return true
	end
end


function CheckHqDeath(victim, killer)
	local vid = victim:vehicletypeid()

	if (vid == g_HqVid) then

		-- Tell the arena an HQ was destroyed
		g_arena:message("&Headquarters> " .. killer.m_name .. " of team " .. killer:getTeam().m_name .. " has destroyed " .. HqOwnedBy .. "'s headquarters.")

		event_destroy(victim:getvarint("ep"))
		DelFromHqTable(victim)
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