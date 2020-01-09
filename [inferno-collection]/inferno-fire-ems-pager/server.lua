-- Inferno Collection Fire/EMS Pager + Fire Siren Version 4.54 Beta
--
-- Copyright (c) 2019, Christopher M, Inferno Collection. All rights reserved.
--
-- This project is licensed under the following:
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to use, copy, modify, and merge the software, under the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. THE SOFTWARE MAY NOT BE SOLD.
--

--
--		Nothing past this point needs to be edited, all the settings for the resource are found ABOVE this line.
--		Do not make changes below this line unless you know what you are doing!
--

-- Master Fire Siren storage variable
local FireSirens = {}

RegisterServerEvent("Fire-EMS-Pager:StoreSiren")
AddEventHandler("Fire-EMS-Pager:StoreSiren", function(Station)
	if not FireSirens[Station.Name:lower()] then
		FireSirens[Station.Name:lower()] = Station
		FireSirens[Station.Name:lower()].ID = source

		TriggerClientEvent("Fire-EMS-Pager:Bounce:ServerValues", -1, FireSirens)
	end
end)

RegisterServerEvent("Fire-EMS-Pager:RemoveSiren")
AddEventHandler("Fire-EMS-Pager:RemoveSiren", function(StationName)
	if FireSirens[StationName] then
		FireSirens[StationName] = nil
	end
end)

-- Plays tones on all clients
RegisterServerEvent("Fire-EMS-Pager:PageTones")
AddEventHandler("Fire-EMS-Pager:PageTones", function(Tones, HasDetails, Details)
	TriggerClientEvent("Fire-EMS-Pager:PlayTones", -1, Tones, HasDetails, Details)
end)

-- Plays cancel sound on all clients
RegisterServerEvent("Fire-EMS-Pager:CancelPage")
AddEventHandler("Fire-EMS-Pager:CancelPage", function(Tones, HasDetails, Details)
	TriggerClientEvent("Fire-EMS-Pager:CancelPage", -1, Tones, HasDetails, Details)
end)

-- Play fire siren on all clients
RegisterServerEvent("Fire-EMS-Pager:SoundSirens")
AddEventHandler("Fire-EMS-Pager:SoundSirens", function()
	TriggerClientEvent("Fire-EMS-Pager:PlaySirens", -1)
end)

-- Whitelist check on server join
RegisterServerEvent("Fire-EMS-Pager:WhitelistCheck")
AddEventHandler("Fire-EMS-Pager:WhitelistCheck", function(Whitelist)
	for i in pairs(Whitelist.Command) do
		Whitelist.Command[i] = "pending"
	end

	-- If usin json file as whitelist
	if Whitelist.Enabled:lower() == "json" then
		-- Collect all the data from the whitelist.json file
		local Data = LoadResourceFile(GetCurrentResourceName(), "whitelist.json")
		if Data then
			local Entries = json.decode(Data)

			-- Loop through the whitelist array
			for _, Entry in ipairs(Entries) do
				-- Check if the player exists in the array.
				if GetPlayerIdentifier(source):lower() == Entry.steamhex:lower() then
					-- Loop though all values in whitelist entry
					for i in pairs(Entry) do
						-- If the value is not the player's steam hex
						if i ~= "steamhex" then
							-- If whitelist value is true, aka they have access to a command
							if Entry[i] then
								-- If command is a valid command
								if Whitelist.Command[i] then
									-- Allow player to use that command
									Whitelist.Command[i] = true
								-- If command is not valid
								else
									print("===================================================================")
									print("==============================WARNING==============================")
									print("/" .. i .. " is not a valid command, but is listed in ")
									print(Entry.steamhex:lower() .. "'s whitelist entry. Please correct this")
									print("issue, and reload the whitelist with /pagerwhitelist reload.")
									print("Note: Entries are CaSe SeNsItIvE.")
									print("===================================================================")
								end
							end
						end
					end

					break
				end
			end
		-- If unable to load json file
		else
			print("===================================================================")
			print("==============================WARNING==============================")
			print("Unable to load whitelist file for Inferno-Fire-EMS-Pager. The white")
			print("list has been disabled. This message will appear every time someone")
			print("joins the server until the issue is corrected.")
			print("===================================================================")
			-- Loop through all commands
			for i in pairs(Whitelist.Command) do
				-- Grant players all permissions
				Whitelist.Command[i] = true
			end
			-- Override whitelist permission
			Whitelist.Command.pagerwhitelist = false
		end

		-- Loop through all commands
		for i in pairs(Whitelist.Command) do
			-- If command is still pending
			if Whitelist.Command[i] == "pending" then
				-- Deny access
				Whitelist.Command[i] = false
			end
		end
	-- If using Ace permissions
	elseif Whitelist.Enabled:lower() == "ace" then
		-- Loop through all commands
		for i in pairs(Whitelist.Command) do
			-- Grant player permission to command based on Ace group
			Whitelist.Command[i] = IsPlayerAceAllowed(source, "fire-ems-pager." .. i)
		end
	-- If using neither json, Ace, or disabled
	else
		print("===================================================================")
		print("==============================WARNING==============================")
		print("''" .. tostring(Whitelist.Enabled) .. "'' is not a valid Whitelist option.")
		print("The whitelist has been disabled.")
		print("===================================================================")
		-- Loop through all commands
		for i in pairs(Whitelist.Command) do
			-- Grant players all permissions
			Whitelist.Command[i] = true
		end
		-- Override whitelist permission
		Whitelist.Command.pagerwhitelist = false
	end

	TriggerClientEvent("Fire-EMS-Pager:return:WhitelistCheck", source, Whitelist)
end)

-- Whitelist reload on all clients
RegisterServerEvent("Fire-EMS-Pager:WhitelistReload")
AddEventHandler("Fire-EMS-Pager:WhitelistReload", function()
	TriggerClientEvent("Fire-EMS-Pager:WhitelistRecheck", -1)
end)

-- Add entry to whitelist (json only)
RegisterServerEvent("Fire-EMS-Pager:WhitelistAdd")
AddEventHandler("Fire-EMS-Pager:WhitelistAdd", function(ID, Entry)
	-- Collect all the data from the whitelist.json file
	local Data = json.decode(LoadResourceFile(GetCurrentResourceName(), "whitelist.json"))

	-- If 'steam hex' provided was a number
	if tonumber(ID) then
		-- Get steam hex based off of number
		ID = GetPlayerIdentifier(ID)
	end

	-- Add the steam hex to the whitelist entry
	Entry.steamhex = ID
	-- Add the entry to the existing whitelist
	table.insert(Data, Entry)
	-- Covert the entire object to a json format, then save it over the existing file
	SaveResourceFile(GetCurrentResourceName(), "whitelist.json", json.encode(Data), -1)

	TriggerClientEvent("Fire-EMS-Pager:WhitelistRecheck", -1)
end)