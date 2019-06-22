-- Inferno Collection Fire/EMS Pager + Fire Siren Version 4.2
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
-- Is the cleint's local pager enabeled
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

-- On client joined, add all chat suggestions
AddEventHandler("onClientMapStart", function()
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
end)

-- Base pager command
-- Used to enable and disable pager, and set tones to be tuned to 
RegisterCommand("pager", function(source, args)
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
			-- Tell GTA that a string will be passed
			SetNotificationTextEntry("STRING")
			-- Create a temporary variable to add more text to
			local notificationText = "~g~Pager tuned to:~y~"
			-- Loop though all the tones that the client will be tuned to
			for z, tone in ipairs(pager.tunedTo) do
				-- Add them to the temporary variable
				notificationText = notificationText .. " " .. tone:upper()
			end
			-- Add temporary variable to notification
			AddTextComponentString(notificationText)
			-- Draw new notifcation on client's screen
			DrawNotification(false, true)
			-- Locally anable the client's pager
			pager.enabled = true
		-- If there is a mismatch, i.e. invalid/no tone/s provided
		else
			-- Tell GTA that a string will be passed
			SetNotificationTextEntry("STRING")
			-- Error that will be passed to notification
			AddTextComponentString("~r~~h~Invalid tones, please check your command arguments.")
			-- Draw new notifcation on client's screen
			DrawNotification(true, true)
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
			-- Tell GTA that a string will be passed
			SetNotificationTextEntry("STRING")
			-- Error that will be passed to notification
			AddTextComponentString("~g~Pager turned off.")
			-- Draw new notifcation on client's screen
			DrawNotification(false, true)
			-- Ensure the client's pager is locally disabled
			pager.enabled = false
			-- Clear list of tones to be tuned to
			pager.tunedTo = {}
		end
	end
end)

-- Base page command
-- Used to page out a tone or tones
RegisterCommand("page", function(source, args)
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
			-- Tell GTA that a string will be passed
			SetNotificationTextEntry("STRING")
            -- Create a temporary variable to add more text to
			local notificationText = "~g~Paging:~y~"
            -- Loop though all the tones
			for z, tone in ipairs(toBePaged) do
                -- Add a tone to temporary string
				notificationText = notificationText .. " " .. tone:upper()
			end
            -- String to be pased to the notification
			AddTextComponentString(notificationText)
            -- Draw notifcation to client's screen
			DrawNotification(false, true)
			-- Bounces tones off of server
			TriggerServerEvent("fire-ems-pager:pageTones", toBePaged)
		-- If there is a mismatch, i.e. invalid/no tone/s provided
		else
			-- Tell GTA that a string will be passed
			SetNotificationTextEntry("STRING")
			-- Error that will be passed to notification
			AddTextComponentString("~r~~h~Invalid tones, please check your command arguments.")
			-- Draw new notifcation on client's screen
			DrawNotification(true, true)
		end
	-- If tones are already being paged
	else
		-- Tell GTA that a string will be passed
        SetNotificationTextEntry("STRING")
        -- Error that will be passed to notification
        AddTextComponentString("~r~~h~Tones are already being paged.")
        -- Draw new notifcation on client's screen
        DrawNotification(true, true)
	end
end)

-- Base fire siren command
-- Used to play a fire siren at a specific station/s
RegisterCommand("firesiren", function(source, args)
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
					-- We can not send vector3s to the server, so it is
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
            -- Tell GTA that a string will be passed
			SetNotificationTextEntry("STRING")
            -- Create a temporary variable to add more text to
			local notificationText = "~g~Sounding:~y~"
            -- Loop though all stations
			for z, station in ipairs(toBeSirened) do
                -- Add station to temporary variable
				notificationText = notificationText .. " " .. station.name:upper()
			end
            -- Pass temporary variable to notifcation
			AddTextComponentString(notificationText)
            -- Draw new notification on client's screen
			DrawNotification(false, true)
			-- Bounces stations off of server
			TriggerServerEvent("fire-ems-pager:soundSirens", toBeSirened)
		-- If there is a mismatch, i.e. invalid/no stations/s provided
		else
            -- Tell GTA that a string will be passed
            SetNotificationTextEntry("STRING")
            -- Error that will be passed to notification
            AddTextComponentString("~r~~h~Invalid stations for sounding, please check your command arguments.")
            -- Draw new notifcation on client's screen
            DrawNotification(true, true)
        end
	-- If sirens are already being sounded
	else
		-- Tell GTA that a string will be passed
		SetNotificationTextEntry("STRING")
        -- Error that will be passed to notification
		AddTextComponentString("~r~~h~Sirens are already being sounded!")
        -- Draw new notifcation on client's screen
		DrawNotification(true, true)
	end
end)

-- Plays tones on the client
RegisterNetEvent("fire-ems-pager:playTones")
AddEventHandler("fire-ems-pager:playTones", function(tones)
	-- Stop tones being paged over the top of others
	pager.paging = true
	-- If the pager is enabled, if not, ignore
	if pager.enabled then
		-- Tell GTA that a string will be passed
		SetNotificationTextEntry("STRING")
        -- String that will be passed to notification
		AddTextComponentString("~g~~h~You pager activates!")
        -- Draw new notifcation on client's screen
		DrawNotification(true, true)
		-- Short pause before tones are played
		Citizen.Wait(1500)
		
		for z, tone in ipairs(tones) do
			local tuned = false
			-- Loop through all the tones we are tuned to
			for x, tunedTone in ipairs(pager.tunedTo) do
				-- If we are tuned to this tone
				if tone == tunedTone then
					tuned = true
				end
			end
			
			-- If we are tuned to this tone
			if tuned then
				-- Send the vibrate tone, since we are tuned to it
				SendNUIMessage({
					transactionType     = "playTone",
					transactionFile     = "vibrate"
				})
				SetNotificationTextEntry("STRING")
				AddTextComponentString("~h~~y~" .. tone:upper() ..  " call!")
				DrawNotification(true, true)
			-- If we are not tuned to it
			else
				-- Send the name of the tone
				SendNUIMessage({
					transactionType     = "playTone",
					transactionFile     = tone
				})
			end
			-- Wait time between tones
			Citizen.Wait(pager.waitTime)
		end
	
		-- Play the ending beeps, to signify that all tones are played
		SendNUIMessage({
			transactionType     = "playTone",
			transactionFile     = "end"
		})
		-- Wait for sound to finish, then allow more tones to be paged
		Citizen.Wait(3000)
		pager.paging = false
	end
end)

-- Play fire sirens
RegisterNetEvent("fire-ems-pager:playSirens")
AddEventHandler("fire-ems-pager:playSirens", function(stations)
	-- Turns coordinates back into vector3
	for z, station in ipairs(stations) do
		newStation = {}
		newStation.name = station.name
		newStation.loc = vector3(station.x, station.y, station.z)
		table.insert(fireSiren.enabledStations, newStation)
	end
	-- Stop sirens being paged over the top of others
	fireSiren.enabled = true
	
	-- Short pause before sirens are played
	Citizen.Wait(1000)
	
	-- Send the sound of the tone
	SendNUIMessage({
		transactionType     = "playSiren"
	})

	-- Wait for sound to finish, then allow more sirens to be sounded
	Citizen.Wait(51000)
	fireSiren.enabled = false
end)

Citizen.CreateThread(function()
    while true do
		Citizen.Wait(0)
		if fireSiren.enabled then
			-- Player position
			local pP = GetEntityCoords(GetPlayerPed(PlayerId()), false)
			-- Find closest station
			local stationDistances = {}
			for x, station in ipairs(fireSiren.stations) do
				local distance = GetDistanceBetweenCoords(pP.x, pP.y, pP.z, station.loc.x, station.loc.y, station.loc.z, true)
				table.insert(stationDistances, {name = station.name, distance = distance + 0.01}) -- Stops divide by 0 errors
			end
			table.sort(stationDistances, function(a, b) return a.distance < b.distance end)
			for x, station in ipairs(fireSiren.enabledStations) do
				if stationDistances[1].name == station.name then
					-- Distance between player and closest station
					local vol = 0
					if (stationDistances[1].distance <= fireSiren.size) then
						vol = (1 - (stationDistances[1].distance / fireSiren.size))
						SendNUIMessage({
							transactionType     = "setSirenVolume",
							volume     			= vol
						})
					else
						SendNUIMessage({
							transactionType     = "setSirenVolume",
							volume     			= vol
						})
					end
				end
			end
		end
	end
end)
