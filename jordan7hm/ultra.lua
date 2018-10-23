--[[ Global Variables ]]--
g_arena = nil
g_skillItemName = "Become: Militiaman"   

-- [[Other Lua Files]] --

dofile("ultraHQ.lua")

-- [[ Functions ]] --
 
-- when the arena is first created, this function is called (whether it is public1 being created, or a private arena -it doesn't matter)
function Arena_OnCreate(arena)        
    g_arena = arena
    math.randomseed(os.time())
end	


function Player_OnVehicleChange(plyr, FromVehicle, ToVehicle, Action)
   if Action == 2 then
      return Player_unspec(plyr)
   elseif Action == 1 then
      --Player_onSpec
   elseif Action == 3 then
      --player_onvehicleenter
   elseif Action == 4 then
      --exit vehicle
   end
   
   return true
end


function Player_unspec(plyr)
     
   if plyr:getVehicle():typeid() == 100 then
		plyr:modItemAmount(g_skillItemName,1)
	end
   
   return true
end

-- when anyone dies in your zone, this function is called, it gives you two objects, the killer and the victim
-- The purpose of this function is to handle dropping of beer / ammunition upon death
function Player_OnDeath(killer, victim)

	--------------------------------------------------------
	-- get the victims coords
	local pos = victim:getCoords()
	
	local ammunition = {}
	-- Beer
	ammunition[0] = "AkenCo Beer"
	-- Standard Ammo
	ammunition[1] = "Ammo - Bullets"
	ammunition[2] = "Ammo - Heavy Rounds"
	ammunition[3] = "Ammo - Shotgun Shells"
	ammunition[4] = "Ammo - Sniper Ammo"
	ammunition[5] = "Ammo -Fuel"
	ammunition[6] = "Ammo - 40mm Grenades"
	-- One use ammo
	ammunition[7] = "Hand Grenade"
	ammunition[8] = "Incendiary Grenade"
	ammunition[9] = "LAW"
	ammunition[10] = "Tire Patch"
	ammunition[11] = "Stim Pack"
	ammunition[12] = "Steron Injection"
	ammunition[13] = "40 of Malt Liquor"
	ammunition[14] = "Anti Warp Unit"
	ammunition[15] = "Cloaking Unit"
	ammunition[16] = "Stealth Unit"

	local amount = {}
	
	-- beer dropping formula
	for x = 0, 0 do
		amount[x] = victim:itemAmount(ammunition[x])
		if (amount[x] > 0) then
			local modifyamount = math.ceil(math.random(30, 50) * amount[x] / 100)
			victim:modItemAmount(ammunition[x], -modifyamount)
			g_arena:createItem(ammunition[x], modifyamount, (math.random(-100, 100) + pos.x), (math.random(-100, 100) + pos.y))
			local newamount = victim:itemAmount(ammunition[x])
			if (newamount == 0) then
				victim:modItemAmount(ammunition[x], 1)
			end		
		end

		if (amount[x] == 0) then
			g_arena:createItem(ammunition[x], 1, (math.random(-50, 50) + pos.x), (math.random(-50, 50) + pos.y))				
		end	
	end

	-- standard ammunition dropping formula
	for x = 1, 16 do
		amount[x] = victim:itemAmount(ammunition[x])
		if (amount[x] > 0) then
			local modifyamount = math.ceil(math.random(15, 30) * amount[x] / 100)
			victim:modItemAmount(ammunition[x], -modifyamount)
			g_arena:createItem(ammunition[x], modifyamount, (math.random(-100, 100) + pos.x), (math.random(-100, 100) + pos.y))
			local newamount = victim:itemAmount(ammunition[x])
			if (newamount == 0) then
				victim:modItemAmount(ammunition[x], 1)
			end
		end
	end
end
