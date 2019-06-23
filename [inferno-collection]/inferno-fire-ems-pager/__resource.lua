-- Inferno Collection Fire/EMS Pager + Fire Siren Version 4.2
--
-- Copyright (c) 2019, Christopher M, Inferno Collection. All rights reserved.
--
-- This project is licensed under the following:
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to use, copy, modify, and merge the software, under the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. THE SOFTWARE MAY NOT BE SOLD.
--

-- Manifest Version
resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

-- Client Script
client_script "client.lua"

-- Server Script
server_script "server.lua"

-- NUI Page
ui_page "html/index.html"

-- Files needed for NUI
files {
	-- Whitelist file
	"whitelist.json",
	-- NUI File
	"html/index.html",
	-- Sound played after all tones have played
	"html/sounds/end.mp3",
	-- Sound played when you are tuned to a paged tone
	"html/sounds/vibrate.mp3",
	-- Fire siren sound
	"html/sounds/firesiren.mp3",
	
	-- Tones, see here for how to add custom tones:
	-- https://github.com/inferno-collection/Fire-EMS-Pager/wiki/Adding-custom-tones
	"html/sounds/rescue.mp3",
	"html/sounds/medical.mp3",
	"html/sounds/fire.mp3",
	"html/sounds/other.mp3"
}
