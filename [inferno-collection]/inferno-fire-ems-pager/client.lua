-- Inferno Collection Fire/EMS Pager + Fire Siren Version 4.4
--
-- Copyright (c) 2019, Christopher M, Inferno Collection. All rights reserved.
--
-- This project is licensed under the following:
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to use, copy, modify, and merge the software, under the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. THE SOFTWARE MAY NOT BE SOLD.
--

--
-- Resource Configuration
-- PLEASE RESTART SERVER AFTER MAKING CHANGES TO THIS CONFIGURATION
--
local config = {} -- Do not edit this line
-- Whether or not to enable chat suggestions
config.chatSuggestions = true
-- Whether or not to enable command whitelist
config.whitelistEnabled = false
-- Separator character, goes between tones and details
-- in /page command
config.pageSep = "-"
-- The name of your fire department, used in page message
config.deptName = "Los Santos Fire"
-- The default text when page details are not provided
config.defaultDetails = "Report to Station"
-- Time in ms between the beginning of each tone played,
-- 7.5 seconds by default, do not edit unless you need to
config.waitTime = 7500
-- The size around the siren source the siren can be heard.
-- Siren gets quieter the further from the origin, so the
-- number below is the further spot it will be able to be heard from
config.size = 400
-- List of tones that can be paged, feel free to add more to this list
-- https://github.com/inferno-collection/Fire-EMS-Pager/wiki/Adding-custom-tones
config.tones = {"medical", "rescue", "fire", "other"}
-- List of stations fire sirens can be played at
-- Feel free to add more stations to this list
-- https://github.com/inferno-collection/Fire-EMS-Pager/wiki/Adding-custom-stations
config.stations = {} -- Do not edit this line
table.insert(config.stations, {name = "pb", loc = vector3(-379.53, 6118.32, 31.85)}) -- Paleto Bay
table.insert(config.stations, {name = "fz", loc = vector3(-2095.92, 2830.22, 32.96)}) -- Fort Zancudo
table.insert(config.stations, {name = "ss", loc = vector3(1691.24, 3585.83, 35.62)}) -- Sandy Shores
table.insert(config.stations, {name = "rh", loc = vector3(-635.09, -124.29, 39.01)}) -- Rockford Hills
table.insert(config.stations, {name = "els", loc = vector3(1193.42, -1473.72, 34.86)}) -- East Los Santos
table.insert(config.stations, {name = "sls", loc = vector3(199.83, -1643.38, 29.8)}) -- South Los Santos
table.insert(config.stations, {name = "dpb", loc = vector3(-1183.13, -1773.91, 4.05)}) -- Del Perro Beach
table.insert(config.stations, {name = "lsia", loc = vector3(-1068.74, -2379.96, 14.05)}) -- LSIA

--
--		Nothing past this point needs to be edited, all the settings for the resource are found ABOVE this line.
--		Do not make changes below this line unless you know what you are doing!
--

-- Local Pager Variables
local pager = {}
-- Is the client's local pager enabled
pager.enabled = false
-- Are all clients currently being paged
pager.paging = false
-- What the client's local pager is tuned to
pager.tunedTo = {}
-- How long to wait between tones being played.
-- All the default tones are around 5-6 seconds long
pager.waitTime = config.waitTime
-- List of tones that can be paged
pager.tones = config.tones

-- Local Fire Siren Variables
local fireSiren = {}
-- Is a fire siren currently being paged
fireSiren.enabled = false
-- Stations that currently have a fire siren being played
fireSiren.enabledStations = {}
-- Fire Station Variables
fireSiren.stations = config.stations
-- The size around the siren source the siren can be heard
fireSiren.size = config.size

-- Local whitelist variable
local whitelist = {}
-- Boolean for whether the whitelist is enabled
whitelist.enabled = config.whitelistEnabled
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
-- Boolean for whether player is whitelisted for cancelpage command
whitelist.command.cancelpage = false

-- On client join server
AddEventHandler("onClientMapStart", function()
	-- If chat suggestions are enabled
	if config.chatSuggestions then
		-- Create a temporary variable to add more text to
		local validTones = "Valid tones:"
		-- Loop though all the tones
		for z, tone in ipairs(pager.tones) do
			-- Add a tone to temporary string
			validTones = validTones .. " " .. tone
		end
		-- Add suggestion and include all valid tones
		TriggerEvent("chat:addSuggestion", "/pager", "From already being tuned, will turn off pager. From the pager being off, enter tones to be tuned to, or if already tuned, tones to be retuned to. Put a space between each tone.", {
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

		-- Add suggestion for cancel
		TriggerEvent("chat:addSuggestion", "/cancelpage", "Plays cancel tone and shows disregard notification.", {
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
		whitelist.command.cancelpage = true
	end

	-- Adds page command chat template
	TriggerEvent("chat:addTemplate", "page", "<img src='data:image/gif;base64,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' height='16'> <b>{0}</b>: {1}")
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
		-- Base pager function, called only from this command
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
	-- Temporary Variable to count provided tones
	local toneCount = 0
	-- Whether the arguments has details or not
	local hasDetails = false
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
						-- No need to keep searching for this tone
						break
					-- Checks for the separator character
					elseif providedTone:lower() == config.pageSep then
						-- Set true, used for checking and loop breaking
						hasDetails = true
						-- Counts up to the number of valid tones provided
						-- plus 1, to include the separator
						for i = toneCount + 1,1,-1 do
							-- Remove tones from arguments to leave details
							table.remove(args, 1)
						end
						-- Break from loop
						break
					end
				end
				-- If a break is needed
				if hasDetails then
					-- Break from loop
					break
				end
				-- Increase count
				toneCount = toneCount + 1
			end
			
			-- If the number of originally provided tones matches the
			-- number of tones, and there where tones acutally provided
			-- in the first place
			if not toneCount ~= #toBePaged and toneCount ~= 0 then
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
				TriggerServerEvent("fire-ems-pager:pageTones", toBePaged, hasDetails, args)
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

-- Base cancelpage command
-- Used to play cancel sound on all clients
RegisterCommand("cancelpage", function(source, args)
	-- Check if the player is whitelisted to use this command
	if whitelist.command.cancelpage then
		-- If tones are not already being paged
		if not pager.paging then
			-- Positive feedback
			newNoti("~g~Paging cancel tone.", true)
			-- Bounce to server
			TriggerServerEvent("fire-ems-pager:cancelPage")
		else
			-- Draw new notification on client's screen
			newNoti("~r~~h~Tones are already being paged.", true)
		end
	else
		-- Draw error message on player screen
		newNoti("~r~You are not whitelisted for this command.", true)
	end
end)

-- Plays tones on the client
RegisterNetEvent("fire-ems-pager:cancelPage")
AddEventHandler("fire-ems-pager:cancelPage", function()
	-- Stop tones being paged over the top of others
	pager.paging = true
	-- If the pager is enabled, if not, ignore
	if pager.enabled then
		-- New NUI message
		SendNUIMessage({
			-- Tell the NUI a tone needs to be played
			transactionType     = "playTone",
			-- Provide ending beeps
			transactionFile     = "cancel"
		})

		-- Send message to chat, only people with pagers can see
		-- the message on their screen
		TriggerEvent("chat:addMessage", {
			-- Use page template
			templateId = "page",
			-- "Fire Control" in red
			color = { 255, 0, 0},
			-- Allow multiline
			multiline = true,
			-- Message
			args = {"Fire Control", "\nAttention " .. config.deptName .. " - Call canceled, disregard response."}
		})
	end
	-- Wait for sound to finish
	Citizen.Wait(3500)
	-- Allow more tones to be paged
	pager.paging = false
end)

-- Plays tones on the client
RegisterNetEvent("fire-ems-pager:playTones")
AddEventHandler("fire-ems-pager:playTones", function(tones, hasDetails, details)
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
					transactionType	= "playTone",
					-- Provide vibration tone
					transactionFile	= "vibrate"
				})
				-- Draw new notification on client's screen
				newNoti("~h~~y~" .. tone:upper() ..  " call!", true)
			-- If player is not tuned to it
			else
				-- New NUI message
				SendNUIMessage({
					-- Tell the NUI a tone needs to be played
					transactionType	= "playTone",
					-- Provide the tone
					transactionFile	= tone
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

		-- Temporary variable for hours
		local hours = GetClockHours()
		-- If hours are less than or equal to 9
		if hours <= 9 then
			-- Add a 0 infront
			hours = "0" .. tostring(hours)
		end
		-- Temporary variable for minutes
		local minutes = GetClockMinutes()
		-- If minutes are less than or equal to 9
		if minutes <= 9 then
			-- Add a 0 infront
			minutes = "0" .. tostring(minutes)
		end

		-- If a location was included
		if hasDetails then
			-- Create a temporary variable for details
			local newDetails = ""
			-- Create a temporary variable for tones
			local newTones = ""

			-- Loop though details (each word is an element)
			for z, l in ipairs(details) do
				-- Add word to temporary variable
				newDetails = newDetails .. " " .. l
			end
			-- Capitalise first letter
			newDetails = newDetails:gsub("^%l", string.upper)

			-- Loop though all tones
			for z, tone in ipairs(tones) do
				-- Add tone to string and capitalise
				newTones = newTones .. tone:gsub("^%l", string.upper) .. " "
			end

			-- Send message to chat, only people with pagers can see
			-- the message on their screen
			TriggerEvent("chat:addMessage", {
				-- Use page template
				templateId = "page",
				-- "Fire Control" in red
				color = { 255, 0, 0},
				-- Allow multiline
				multiline = true,
				-- Message
				args = {"Fire Control", "\nAttention " .. config.deptName .. " - " .. newDetails .. " - " .. newTones .. "Emergency.\n\nTimeout " .. hours .. minutes.. "."}
			})
		else
			-- Send message to chat, only people with pagers can see
			-- the message on their screen
			TriggerEvent("chat:addMessage", {
				-- Use page template
				templateId = "page",
				-- "Fire Control" in red
				color = { 255, 0, 0},
				-- Allow multiline
				multiline = true,
				-- Message
				args = {"Fire Control", "\nAttention " .. config.deptName .. " - " .. config.defaultDetails .. ".\n\nTimeout " .. hours .. minutes.. "."}
			})
		end
	end
	-- Wait for sound to finish
	Citizen.Wait(3000)
	-- Allow more tones to be paged
	pager.paging = false
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
		transactionType = "playSiren"
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
			local pP = GetEntityCoords(GetPlayerPed(-1), false)
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
					-- If the distance to the closest station is within the fire siren radius
					if (stationDistances[1].distance <= fireSiren.size) then
						-- Volume is equal to 1 (max volume) mius the distance to the nearest station from the player
						-- divided the radius of the fire siren
						-- New NUI message
						SendNUIMessage({
							-- Tell the NUI to set the sire volume
							transactionType	= "setSirenVolume",
							-- The volume
							volume			= 1 - (stationDistances[1].distance / fireSiren.size)
						})
					-- If the cloest station is out of the radius of the fire siren
					else
						-- New NUI message
						SendNUIMessage({
							-- Tell the NUI to set the sire volume
							transactionType	= "setSirenVolume",
							-- The volume
							volume     		= 0
						})
					end
				end
			end
		end
	end
end)