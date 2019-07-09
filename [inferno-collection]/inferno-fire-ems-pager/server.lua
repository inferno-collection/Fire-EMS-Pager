-- Inferno Collection Fire/EMS Pager + Fire Siren Version 4.4
--
-- Copyright (c) 2019, Christopher M, Inferno Collection. All rights reserved.
--
-- This project is licensed under the following:
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to use, copy, modify, and merge the software, under the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. THE SOFTWARE MAY NOT BE SOLD.
--

-- Play tones on all clients
RegisterServerEvent("fire-ems-pager:pageTones")
AddEventHandler("fire-ems-pager:pageTones", function(tones, hasDetails, details)
	TriggerClientEvent("fire-ems-pager:playTones", -1, tones, hasDetails, details)
end)

-- Play cancel sound on all clients
RegisterServerEvent("fire-ems-pager:cancelPage")
AddEventHandler("fire-ems-pager:cancelPage", function()
	TriggerClientEvent("fire-ems-pager:cancelPage", -1)
end)

-- Play fire siren on all clients
RegisterServerEvent("fire-ems-pager:soundSirens")
AddEventHandler("fire-ems-pager:soundSirens", function(stations)
	TriggerClientEvent("fire-ems-pager:playSirens", -1, stations)
end)

-- Whitelist check on server join
RegisterServerEvent("fire-ems-pager:whitelistCheck")
AddEventHandler("fire-ems-pager:whitelistCheck", function()
	-- Local whitelist variable
	local whitelist = {}
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
	-- Collect all the data from the whitelist.json file
	local data = LoadResourceFile(GetCurrentResourceName(), "whitelist.json")
	-- If able to collect data
	if data then
		-- Place the decoded whitelist into the array
		whitelist.ids = json.decode(data)
		
		-- Loop through the whitelist array
		for x, wId in ipairs(whitelist.ids) do
			-- Check if the player exists in the array.
			if GetPlayerIdentifier(source):lower() == wId.steamhex:lower() then
				-- Set the player's permissions based off of the whitelist file
				whitelist.command.pager = wId.pager
				whitelist.command.page = wId.page
				whitelist.command.firesiren = wId.firesiren
				whitelist.command.cancelpage = wId.cancelpage
				-- Break the loop, no more searching needed
				break
			end
		end
	-- If unable to load json file
	else
		-- Print error message to server console
		print("===================================================================")
		print("==============================WARNING==============================")
		print("Unable to load whitelist file for Inferno-Fire-EMS-Pager. The white")
		print("list has been disabled. This message will appear every time someone")
		print("joins the server until the issue is corrected.")
		print("===================================================================")
		-- Grant player all permissions so the resource is not totally broken
		whitelist.command.pager = true
		whitelist.command.page = true
		whitelist.command.firesiren = true
		whitelist.command.cancelpage = true
	end	
	TriggerClientEvent("fire-ems-pager:return:whitelistCheck", source, whitelist.command)
end)