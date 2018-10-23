g_arena = nil
g_specVehID = 1
g_skillItemName = "Become: Marine"   

function Arena_OnCreate(arena)
   g_arena = arena
end

function Player_OnUnspec(plyr, toVehicle)
   if plyr:getVehicle():typeid() == g_specVehID then
      plyr:modItemAmount(g_skillItemName,1)
   end

   return true
end