--team functions
-- Teams.txt -- Holds the teams and their info
-- TeamPlayers.txt -- Holds the player name and the team they 'belong' too
function Msg_OnCommand(player, command, payload, recipient, msg_type)
	-- TEAM COMMAND FUNCTIONS
	if (command == "?teamcreate") then
		if (payload == "") then
			player:message("Incorrect syntax, use: ?teamcreate <name>:<password>")
		else
			-- Get the team name and password from the payload
			local teamname = string.gsub(payload, "(.-)(%:)(.+)", "%1")
			local teampassword = string.gsub(payload, "(.-)(%:)(.+)", "%3")
			
			-- See if there is already a team with this name
			local teamexists = false
			for line in io.lines("Teams.txt") do		
				if (string.lower(teamname) == string.lower(string.gsub(line, "TeamName:(.+),TeamPassword:(.+)", "%1"))) then
					teamexists = true
				end
			end
			
			if (teamexists == true) then
				player:message("A team by this name already exists")
			else
				local myFile = io.open("Teams.txt", "a+")
				myFile:write("TeamName:" .. teamname .. ",TeamPassword:" .. teampassword .."\n")
				myFile:close()
				
				player:message("Team: " .. teamname .. " has been created with the password: " .. teampassword)
			end
		end
	elseif (command == "?teamjoin") then
		if (payload == "") then
			player:message("Incorrect syntax, use: ?teamjoin <name>:<password>")
		else
			local playerhasteam = false
			for line in io.lines("TeamPlayers.txt") do		
				if (string.lower(player.m_name) == string.lower(string.gsub(line, "PlayerName:(.+),TeamName:(.+)", "%1"))) then
					playerhasteam = true
				end
			end
			
			if (playerhasteam == true) then
				player:message("You are already a part of a team, and cannot change for now")
			else
				local teamname = string.gsub(payload, "(.-)(%:)(.+)", "%1")
				local teampassword = string.gsub(payload, "(.-)(%:)(.+)", "%3")
				local namecorrect = false
				local passcorrect = false
				local teamfound = false
			
				-- Go through the teams and see if that one exists
				for line in io.lines("Teams.txt") do	
					local tempteamname = string.gsub(line, "TeamName:(.+),TeamPassword:(.+)", "%1")
					local tempteampassword = string.gsub(line, "TeamName:(.+),TeamPassword:(.+)", "%2")
					if (string.lower(teamname) == string.lower(tempteamname)) and (string.lower(teampassword) == string.lower(tempteampassword)) then
						local myFile = io.open("TeamPlayers.txt", "a+")
						myFile:write("PlayerName:" .. player.m_name .. ",TeamName:" .. teamname .."\n")
						myFile:close()
						player:message("You are now a part of team: " .. teamname)
						teamfound = true
					end
				end
				
				if (teamfound == false) then
					player:message("That team and/or password could not be found")
				end
			end
		end
	end
end