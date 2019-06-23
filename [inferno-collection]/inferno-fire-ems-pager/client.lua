-- Inferno Collection Fire/EMS Pager + Fire Siren Version 4.35
--
-- Copyright (c) 2019, Christopher M, Inferno Collection. All rights reserved.
--
-- This project is licensed under the following:
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to use, copy, modify, and merge the software, under the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. THE SOFTWARE MAY NOT BE SOLD.
--

-- Local Pager Variables
local pager = {}
-- Is the cleint's local pager enabled
pager.enabled = false
-- Are all clients currently being paged
pager.paging = false
-- What the client's local pager is tuned to, nothing by
-- default, set by command
pager.tunedTo = {}
-- How long to wait between tones being played.
-- All the default tones are around 5-6 seconds long
pager.waitTime = 7500
-- List of tones, feel free to add more to this list
-- https://github.com/inferno-collection/Fire-EMS-Pager/wiki/Adding-custom-tones
pager.tones = {"medical", "rescue", "fire", "other"}

-- Local Fire Siren Variables
local fireSiren = {}
-- Is a fire siren curreltly being paged
fireSiren.enabled = false
-- Stations that currently have a fire siren being played at them
fireSiren.enabledStations = {}
-- Fire Station Variables
fireSiren.stations = {}
-- Feel free to add more to this list
-- https://github.com/inferno-collection/Fire-EMS-Pager/wiki/Adding-custom-stations
table.insert(fireSiren.stations, {name = "pb", loc = vector3(-379.53, 6118.32, 31.85)}) -- Paleto Bay
table.insert(fireSiren.stations, {name = "fz", loc = vector3(-2095.92, 2830.22, 32.96)}) -- Fort Zancudo
table.insert(fireSiren.stations, {name = "ss", loc = vector3(1691.24, 3585.83, 35.62)}) -- Sandy Shores
table.insert(fireSiren.stations, {name = "rh", loc = vector3(-635.09, -124.29, 39.01)}) -- Rockford Hills
table.insert(fireSiren.stations, {name = "els", loc = vector3(1193.42, -1473.72, 34.86)}) -- East Los Santos
table.insert(fireSiren.stations, {name = "sls", loc = vector3(199.83, -1643.38, 29.8)}) -- South Los Santos
table.insert(fireSiren.stations, {name = "dpb", loc = vector3(-1183.13, -1773.91, 4.05)}) -- Del Perro Beach
table.insert(fireSiren.stations, {name = "lsia", loc = vector3(-1068.74, -2379.96, 14.05)}) -- LSIA
-- The size around the siren source the siren can be heard.
-- Siren gets quieter the further from the origin, so the
-- number below is the further spot it will be able to be
-- heard from
fireSiren.size = 400

-- Local chat suggestions variable
-- Whether or not to enable chat suggestions
local chatSuggestions = true

-- Local whitelist variable
local whitelist = {}
-- Boolean for whether the whitelist is enabled
whitelist.enabled = true
-- All whitelisted ids
whitelist.ids = {}
-- Whitelist variable for commands
whitelist.command = {}
-- Boolean for whether player is whitelisted for pager command
whitelist.command.pager = false
-- Boolean for whether player is whitelisted for page command
whitelist.command.page = false
-- Boolean for whether player is whitelisted for firesiren command
whitelist.command.firesiren = false

-- On client joined, add all chat suggestions
AddEventHandler("onClientMapStart", function()
	-- If chat suggestions are enabled
	if chatSuggestions then
		-- Create a temporary variable to add more text to
		local validTones = "Valid tones:"
		-- Loop though all the tones
		for z, tone in ipairs(pager.tones) do
			-- Add a tone to temporary string
			validTones = validTones .. " " .. tone
		end
		-- Add suggestion and include all valid tones
		TriggerEvent("chat:addSuggestion", "/pager", "From already being tuned, will turn off pager. From the pager being off, enter the tones you want to be tuned to, or if already tuned, all the tones you want to be retuned to. Put a space between each tone.", {
			{ name = "tone", help = validTones }
		})
		TriggerEvent("chat:addSuggestion", "/page", "If no other tones are currently being paged, will page entered tones. Put a space between each tone.", {
			{ name = "tones", help = validTones }
		})
		
		-- Create a temporary variable to add more text to
		local validStations = "Valid stations:"
		-- Loop though all the stations
		for z, station in ipairs(fireSiren.stations) do
			-- Add a station to temporary string
			validStations = validStations .. " " .. station.name
		end
		-- Add suggestion and include all valid stations
		TriggerEvent("chat:addSuggestion", "/firesiren", "If no other sirens are currently being sounded, will page fire siren at entered stations. Put a space between each station.", {
			{ name = "stations", help = validStations }
		})
	end
	
	-- If the whitelisted is enabled
	if whitelist.enabled then
		TriggerServerEvent("fire-ems-pager:whitelistCheck")
	else
		-- Grant player all permissions becuase the whitelist is disabled
		whitelist.command.pager = true
		whitelist.command.page = true
		whitelist.command.firesiren = true
	end
end)

-- Return from whitelist check
RegisterNetEvent("fire-ems-pager:return:whitelistCheck")
AddEventHandler("fire-ems-pager:return:whitelistCheck", function(newWhitelist)
	-- Update local whitelist command values with server ones
	whitelist.command = newWhitelist
end)

-- Base pager command
-- Used to enable and disable pager, and set tones to be tuned to 
RegisterCommand("pager", function(source, args)
	-- Check if the player is whitelisted to use this command
	if whitelist.command.pager then
		function enablePager()
			-- Loop though all the tones provided by the client
			for z, providedTone in ipairs(args) do
				-- Loop through all the valid tones
				for x, validTone in ipairs(pager.tones) do
					-- If a provided tone matches a valid tone
					if providedTone:lower() == validTone then
						-- Add it to the list of tones to be tuned to 
						table.insert(pager.tunedTo, validTone)
					end
				end
			end
			
			-- If the number of originally provided tones matches the
			-- number of tones, and there where tones acutally provided
			-- in the first place
			if not #args ~= #pager.tunedTo and #args ~= 0 then
				-- Create a temporary variable to add more text to
				local notificationText = "~g~Pager tuned to:~y~"
				-- Loop though all the tones that the client will be tuned to
				for z, tone in ipairs(pager.tunedTo) do
					-- Add them to the temporary variable
					notificationText = notificationText .. " " .. tone:upper()
				end
				-- Draw new notification on client's screen
				newNoti(notificationText, false)
				-- Locally anable the client's pager
				pager.enabled = true
			-- If there is a mismatch, i.e. invalid/no tone/s provided
			else
				-- Draw new notification on client's screen
				newNoti("~r~~h~Invalid tones, please check your command arguments.", true)
				-- Ensure the client's pager is locally disabled
				pager.enabled = false
				-- Clear list of tones to be tuned to
				pager.tunedTo = {}
			end
		end
		
		
		-- If pager is currently off
		if not pager.enabled then
			-- Attempt to enable pager
			enablePager()
		-- If pager is disabled
		else
			-- If there are tones provided
			if #args ~= 0 then
				-- Clear list of currently tuned tones to avoid duplicates
				pager.tunedTo = {}
				-- Attempt to enable pager
				enablePager()
			-- If no tones where provided, and they just want it turned off
			else
				-- Draw new notification on client's screen
				newNoti("~g~Pager turned off.", false)
				-- Ensure the client's pager is locally disabled
				pager.enabled = false
				-- Clear list of tones to be tuned to
				pager.tunedTo = {}
			end
		end
	-- If player is not whitelisted
	else
		-- Draw error message on player screen
		newNoti("~r~You are not whitelisted for this command.", true)
	end
end)

-- Base page command
-- Used to page out a tone or tones
RegisterCommand("page", function(source, args)
	-- Check if the player is whitelisted to use this command
	if whitelist.command.page then
		-- If tones are not already being paged
		if not pager.paging then
			-- Local array to store tones to be paged
			local toBePaged = {}
			-- Loop though all the tones provided in the command
			for z, providedTone in ipairs(args) do
				-- Loop through all the valid tones
				for x, validTone in ipairs(pager.tones) do
					-- If a provided tone matches a valid tone
					if providedTone:lower() == validTone then
						-- Add it to the list of tones to be paged 
						table.insert(toBePaged, validTone)
					end
				end
			end
			
			-- If the number of originally provided tones matches the
			-- number of tones, and there where tones acutally provided
			-- in the first place
			if not #args ~= #toBePaged and #args ~= 0 then
				-- Create a temporary variable to add more text to
				local notificationText = "~g~Paging:~y~"
				-- Loop though all the tones
				for z, tone in ipairs(toBePaged) do
					-- Add a tone to temporary string
					notificationText = notificationText .. " " .. tone:upper()
				end
				-- Draw new notification on client's screen
					newNoti(notificationText, false)
				-- Bounces tones off of server
				TriggerServerEvent("fire-ems-pager:pageTones", toBePaged)
			-- If there is a mismatch, i.e. invalid/no tone/s provided
			else
				-- Draw new notification on client's screen
				newNoti("~r~~h~Invalid tones, please check your command arguments.", true)
			end
		-- If tones are already being paged
		else
			-- Draw new notification on client's screen
			newNoti("~r~~h~Tones are already being paged.", true)
		end
	-- If player is not whitelisted
	else
		-- Draw error message on player screen
		newNoti("~r~You are not whitelisted for this command.", true)
	end
end)

-- Base fire siren command
-- Used to play a fire siren at a specific station/s
RegisterCommand("firesiren", function(source, args)
	-- Check if the player is whitelisted to use this command
	if whitelist.command.firesiren then
		-- If fire sirens are not already being sounded
		if not fireSiren.enabled then
			-- Local array to store stations to be sounded
			local toBeSirened = {}
			-- Loop though all the stations provided in the command
			for z, providedStation in ipairs(args) do
				-- Loop through all the valid stations
				for x, validStation in ipairs(fireSiren.stations) do
					-- If a provided station matches a valid station
					if providedStation:lower() == validStation.name then
						-- Temporary array for station information
						local newStation = {}
						-- Add station name to new array
						newStation.name = validStation.name
						-- Vector3's cannot be sent to the server, so it is
						-- stored as 3 new variables and add it to new array
						newStation.x, newStation.y, newStation.z = table.unpack(validStation.loc)
						-- Add it to the list of stations to be sounded
						table.insert(toBeSirened, newStation)
					end
				end
			end
			
			-- If the number of originally provided stations matches
			-- the number of stations, and there where stations acutally
			-- provided in the first place
			if not #args ~= #toBeSirened and #args ~= 0 then
				-- Create a temporary variable to add more text to
				local notificationText = "~g~Sounding:~y~"
				-- Loop though all stations
				for z, station in ipairs(toBeSirened) do
					-- Add station to temporary variable
					notificationText = notificationText .. " " .. station.name:upper()
				end
				-- Draw new notification on client's screen
				newNoti(notificationText, false)
				-- Bounces stations off of server
				TriggerServerEvent("fire-ems-pager:soundSirens", toBeSirened)
			-- If there is a mismatch, i.e. invalid/no stations/s provided
			else
				-- Draw new notification on client's screen
				newNoti("~r~~h~Invalid stations for sounding, please check your command arguments.", true)
			end
		-- If sirens are already being sounded
		else
			-- Draw new notification on client's screen
			newNoti("~r~~h~Sirens are already being sounded!", true)
		end
	-- If player is not whitelisted
	else
		-- Draw error message on player screen
		newNoti("~r~You are not whitelisted for this command.", true)
	end
end)

-- Plays tones on the client
RegisterNetEvent("fire-ems-pager:playTones")
AddEventHandler("fire-ems-pager:playTones", function(tones)
	-- Stop tones being paged over the top of others
	pager.paging = true
	-- If the pager is enabled, if not, ignore
	if pager.enabled then
        -- Draw new notification on client's screen
		newNoti("~g~~h~You pager activates!", true)
		-- Short pause before tones are played
		Citizen.Wait(1500)
		
		-- Loop though all tones that need to be paged
		for z, tone in ipairs(tones) do
			-- Temporary boolean variable
			local tuned = false
			-- Loop through all the tones the player is tuned to
			for x, tunedTone in ipairs(pager.tunedTo) do
				-- If player is tuned to this tone
				if tone == tunedTone then
					-- Set temporary variable
					tuned = true
				end
			end
			
			-- If player is tuned to this tone
			if tuned then
				-- New NUI message
				SendNUIMessage({
					-- Tell the NUI a tone needs to be played
					transactionType     = "playTone",
					-- Provide vibration tone
					transactionFile     = "vibrate"
				})
				-- Draw new notification on client's screen
				newNoti("~h~~y~" .. tone:upper() ..  " call!", true)
			-- If player is not tuned to it
			else
				-- New NUI message
				SendNUIMessage({
					-- Tell the NUI a tone needs to be played
					transactionType     = "playTone",
					-- Provide the tone
					transactionFile     = tone
				})
			end
			-- Wait time between tones
			Citizen.Wait(pager.waitTime)
		end
	
		-- New NUI message
		SendNUIMessage({
			-- Tell the NUI a tone needs to be played
			transactionType     = "playTone",
			-- Provide ending beeps
			transactionFile     = "end"
		})
		-- Wait for sound to finish
		Citizen.Wait(3000)
		-- Aallow more tones to be paged
		pager.paging = false
	end
end)

-- Play fire sirens
RegisterNetEvent("fire-ems-pager:playSirens")
AddEventHandler("fire-ems-pager:playSirens", function(stations)
	-- Loop though all stations
	for z, station in ipairs(stations) do
		-- Temporary array
		newStation = {}
		-- Set temporary name
		newStation.name = station.name
		-- Set temporary name and turn coordinates variables back into Vector3
		newStation.loc = vector3(station.x, station.y, station.z)
		-- Insert temporary array into enabled stations
		table.insert(fireSiren.enabledStations, newStation)
	end
	-- Stop sirens being paged over the top of others
	fireSiren.enabled = true
	-- Short pause before sirens are played
	Citizen.Wait(1000)
	
	-- New NEI message
	SendNUIMessage({
		-- Tell the NUI to play the siren sound
		transactionType     = "playSiren"
	})

	-- Wait for sound to finish
	Citizen.Wait(51000)
	-- Then allow more sirens to be sounded
	fireSiren.enabled = false
end)

-- Draws notification on client's screen
function newNoti(text, flash)
	-- Tell GTA that a string will be passed
	SetNotificationTextEntry("STRING")
	-- Pass temporary variable to notification
	AddTextComponentString(text)
	-- Draw new notification on client's screen
	DrawNotification(flash, true)
end

-- Resource master loop
Citizen.CreateThread(function()
	-- Forever
    while true do
		-- Allows safe looping
		Citizen.Wait(0)
		-- If fire siren is enabled
		if fireSiren.enabled then
			-- Get player position
			local pP = GetEntityCoords(GetPlayerPed(PlayerId()), false)
			-- Temporary array
			local stationDistances = {}
			-- Loop though all valid stations
			for x, station in ipairs(fireSiren.stations) do
				-- Calculate distance between player and station
				local distance = GetDistanceBetweenCoords(pP.x, pP.y, pP.z, station.loc.x, station.loc.y, station.loc.z, true)
				-- Insert distance into temporary array
				table.insert(stationDistances, {name = station.name, distance = distance + 0.01}) -- Stops divide by 0 errors
			end
			-- Sort array so the closest station to the player is first
			table.sort(stationDistances, function(a, b) return a.distance < b.distance end)
			-- Loop though all enabled stations
			for x, station in ipairs(fireSiren.enabledStations) do
				-- If the closest station to the player is an enabled station
				if stationDistances[1].name == station.name then
					-- Temporary volume variable
					local vol = 0
					-- If the distance to the closest station is within the fire siren radius
					if (stationDistances[1].distance <= fireSiren.size) then
						-- Volume is equal to 1 (max volume) mius the distance to the nearest station from the player
						-- divided the radius of the fire siren
						vol = (1 - (stationDistances[1].distance / fireSiren.size))
						-- New NUI message
						SendNUIMessage({
							-- Tell the NUI to set the sire volume
							transactionType     = "setSirenVolume",
							-- The volume
							volume     			= vol
						})
					-- If the cloest station is out of the radius of the fire siren
					else
						-- New NUI message
						SendNUIMessage({
							-- Tell the NUI to set the sire volume
							transactionType     = "setSirenVolume",
							-- The volume (0 in this case)
							volume     			= vol
						})
					end
				end
			end
		end
	end
end)