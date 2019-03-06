g_HqTable = {nil}						-- Table that keeps track of all the HQ in the game.  I believe I made it 1 based
g_HqTableSize = 0						-- the g_HqTable size.  It is used for keeping track of how many entries are in the table
g_HqItemMaker = 106 					-- the warp item which creates the HQ  (The headquarters item maker is nothing but a warp item in the .itm file)
g_HqItemMakerName = "Build Warp Pad"	-- the warp item's name (this was a work around since I can't modify inventory based on item number from the .itm file)
g_HqVid = 425							-- the HQ vehicle ID
g_HqMaxAllowed = 1						-- the maximum amount of HQ you are allowed to have.  Technically you have have more if you steal one with a control item
g_WarpToHqItem = 108
g_WarpToHqItemName = "Base Recall"


-- Check to see if the player is warping to an HQ, or creating an HQ
function Player_OnWarpItem(user, itemid, target)
	-- check to see if the warp item was the item used to create an HQ
	if (itemid == g_HGItemMaker) then
		HqItemMaker(user, itemid, target)
		return false
	elseif (itemid == g_WarpToHqItem) then
		WarpToHQ(user)
		return false
	else
		return true
	end
end

-- HQ Creation Functions
-- Check to see if a headquarters was created, and it so create it and add it to the HQ table
function HqItemMaker(user, itemid, target)
	-- add code so there is a limit to the number of HQ
	if (itemid == g_HqItemMaker) then
		-- First loop through all the HQ and see if this team already possess one
		for i = 1, g_HqTableSize do
			local HqCheck = g_HqTable[i]
			if (HqCheck:frequency() == user:frequency() and HqCheck:health() ~= 0) then
				user:message("&Headquarters> Your team already has the maximum amount of headquarters in their possesion")
				-- Give the guy his kit back
				user:modItemAmount(g_HqItemMakerName, 1)
				return false
			end
		end
		-- create the HQ
		CreateHq(user:coords(), user:frequency())

		return true
	else
		return false
	end
end

function CreateHq(pos, freq)
		local HQ = g_arena:createVehicle(g_HqVid, pos.x, pos.y, pos.rotation)
		HQ:setFrequency(freq)
		AddToHqTable(HQ)
		MessageTeam(freq, "&Headquarters> A new headquarters has been created for your team")
end

function AddToHqTable(HQ)
		g_HqTableSize = g_HqTableSize + 1
		g_HqTable[g_HqTableSize] = HQ
end

-- HQ Death Functions
-- Check to see if the vehicle destroyed was the HQ and if so, delete it from the HQ table
function Vehicle_OnDeath(victim,killer)
	-- if it is an headquarters, do this
	CheckHqDeath(victim,killer)
	return true
end


function CheckHqDeath(victim, killer)
	local vid = victim:getVehicle():typeid()

	if (vid == g_HqVid) then
		DelFromHqTable(victim)
	end

end

function DelFromHqTable(HQ)
	local i = 0
	while i < g_HqTableSize do
		i = i + 1
		local xHQ = g_HqTable[i]
		if (HQ:id() == xHQ:id()) then
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
		user:modItemAmount(g_WarpToHqItemName,1)
		return false
	else
		local rNum = math.random(1, teamHQsize)
		local HQ = teamHQ[rNum]
		local pos = HQ:getCoords()
		user:warp(pos.x, pos.y, 0)
		return true
	end
end

