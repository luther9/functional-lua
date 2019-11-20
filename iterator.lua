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

-- Iterate through integers, from start to stop. The default value of start is
-- 1. If stop is nil, the iteration never ends.
local function count(start, stop)
  local i = start or 1
  return function()
    if stop and i > stop then
      return
    end
    return count(i + 1, stop), i
  end
end

local function filter(f, iter)

  local function seek(iter, v)
    if not iter then
      return
    end
    if f(v) then
      return filter(f, iter), v
    end
    return seek(iter())
  end

  return function()
    return seek(iter())
  end
end

local function map(f, iter)
  return function()
    local iter_, v = iter()
    if not iter_ then
      return
    end
    return map(f, iter_), f(v)
  end
end

local function reduce(f, iter, init)
  local iter_, v = iter()
  if not iter_ then
    return init
  end
  return reduce(f, iter_, f(init, v))
end

local function toFor(iter)
  return function(_, f) return f() end, nil, iter
end

local function forEach(f, iter)
  for _, v in toFor(iter) do
    f(v)
  end
end

local function fromFor(iter, state, key)
  return function()
    local v = table.pack(iter(state, key))
    local key_ = v[1]
    if key_ == nil then
      return
    end
    return fromFor(iter, state, key_), v
  end
end

-- All arguments must be iterators. Yield tuples of one element from each
-- iterator. Stop if any of the iterators end.
local function zip(...)
  local iters = {...}
  return function()
    local iters_ = {}
    local values = {}
    for i, iter in ipairs(iters) do
      local iter_, v = iter()
      if not iter_ then
	return
      end
      iters_[i] = iter_
      values[i] = v
    end
    return zip(table.unpack(iters_)), values
  end
end

local function unpack(iter)
  local iter_, v = iter()
  if not iter_ then
    return
  end
  return v, unpack(iter_)
end

local function array(iter)
  return {unpack(iter)}
end

return {
  array = array,
  count = count,
  filter = filter,
  forEach = forEach,
  fromFor = fromFor,
  map = map,
  reduce = reduce,
  toFor = toFor,
  unpack = unpack,
  zip = zip,
}
