-- Inferno Collection Fire/EMS Pager + Fire Siren Version 4.55 Beta
--
-- Copyright (c) 2019, Christopher M, Inferno Collection. All rights reserved.
--
-- This project is licensed under the following:
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to use, copy, modify, and merge the software, under the following conditions:
-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
-- THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. THE SOFTWARE MAY NOT BE SOLD.
--

name 'Fire/EMS Pager + Fire Siren - Inferno Collection'

description 'The Fire/EMS Pager + Fire Siren is a resource that allows players to have a pager on their person at all times.'

author 'Inferno Collection (inferno-collection.com)'

version '4.55 Beta'

url 'https://inferno-collection.com'

client_script 'client.lua'

server_script 'server.lua'

ui_page 'html/index.html'

files {
    'whitelist.json',
    'html/index.html',
    'html/sounds/*.mp3'
}

fx_version 'bodacious'

game 'gta5'
