#!/usr/bin/env lua

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

local iterator = require'iterator'

local iter0 = iterator.count(1, 1)
local iter1, n = iter0()
assert(n == 1)
assert(iter1() == nil)

local iter0 = iterator.filter(
  function(x) return x % 2 == 0 end,
  iterator.count(1, 3))
local iter1, n = iter0()
assert(n == 2)
assert(iter1() == nil)

local iter0 = iterator.map(function(x) return x * 2 end, iterator.count(1, 1))
local iter1, n = iter0()
assert(n == 2)
assert(iter1() == nil)

assert(
  iterator.reduce(function(sum, x) return sum + x end, iterator.count(1, 10), 0)
  == 55)

local t = {}
iterator.forEach(function(x) t[x] = x end, iterator.count(1, 2))
assert(t[1] == 1)
assert(t[2] == 2)
