--[[
Copyright 2019 Luther Thompson

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

local Array = require'array'

local a = Array()
assert(#a == 0)

local a = Array(3, 4)
assert(a[1] == 3)
assert(a[2] == 4)

local a = Array.copy{3, 4}
assert(a[1] == 3)
assert(a[2] == 4)

local iter0 = Array(10):iterator()
local iter1, v = iter0()
assert(v[1] == 1)
assert(v[2] == 10)
assert(iter1() == nil)
