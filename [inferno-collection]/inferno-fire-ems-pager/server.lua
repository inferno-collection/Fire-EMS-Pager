-- Inferno Collection Fire/EMS Pager + Fire Siren Version 4.2
--
-- Copyright (c) 2019, Christopher M, Inferno Collection. All rights reserved.
--
-- This project is licensed under the following:
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to use, copy, modify, and merge the software, under the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. THE SOFTWARE MAY NOT BE SOLD.
--

-- Play tones
RegisterServerEvent("fire-ems-pager:pageTones")
AddEventHandler("fire-ems-pager:pageTones", function(tones)
	TriggerClientEvent("fire-ems-pager:playTones", -1, tones)
end)

-- Play fire sirens
RegisterServerEvent("fire-ems-pager:soundSirens")
AddEventHandler("fire-ems-pager:soundSirens", function(stations)
	TriggerClientEvent("fire-ems-pager:playSirens", -1, stations)
end)
