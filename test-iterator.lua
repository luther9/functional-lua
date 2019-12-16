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

local Iterator = require'iterator'

local iter0 = Iterator.count(1, 1)
local iter1, n = iter0()
assert(n == 1)
assert(iter1() == nil)

local iter0 = Iterator.count(1, 3).filter(function(x) return x % 2 == 0 end)
local iter1, n = iter0()
assert(n == 2)
assert(iter1() == nil)

local iter0 = Iterator.count(1, 1).map(function(x) return x * 2 end)
local iter1, n = iter0()
assert(n == 2)
assert(iter1() == nil)

assert(
  Iterator.count(1, 10).reduce(function(sum, x) return sum + x end, 0) == 55)

local t = {}
Iterator.count(1, 2).forEach(function(x) t[x] = x end)
assert(t[1] == 1)
assert(t[2] == 2)

local iter0 = Iterator.fromFor(ipairs{'one'})
local iter1, v = iter0()
assert(v[1] == 1)
assert(v[2] == 'one')
assert(iter1() == nil)

local t = Iterator.count(10, 11).array
assert(t[1] == 10)
assert(t[2] == 11)

local iter0 = Iterator.zip(Iterator.count(1, 1), Iterator.count(2, 2))
local iter1, arr = iter0()
assert(arr[1] == 1)
assert(arr[2] == 2)
assert(iter1() == nil)

local iter = Iterator.count(1, 4)
assert(iter.sum == 10)
assert(iter.product == 24)

local iter = Iterator
  .fromFor(ipairs{'a', 'b', 'c'})
  .map(function(v) return v[2] end)
assert(iter.concat == 'abc')

local iter0 = Iterator.count(1, 1).zip(Iterator.count(2, 2))
local iter1, arr = iter0()
assert(arr[1] == 1)
assert(arr[2] == 2)
assert(iter1() == nil)
