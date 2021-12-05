#!/usr/bin/env lua

--[[
Copyright 2018 Luther Thompson

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License (GPL3) as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

You have the following additional permission: You may convey the program in
object code form under the terms of sections 4 and 5 of GPL3 without being
bound by section 6 of GPL3.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

local function searcher(modulename)
  local filename
  if modulename == 'functional' then
    filename = 'init.lua'
  else
    filename = modulename:match('functional/(.+)')
  end
  if filename then
    local module <const> = loadfile(filename)()
    return function() return module end, filname
  end
end

table.insert(package.searchers, 2, searcher)

require'test-list'
require'test-iterator'
require'test-array'
