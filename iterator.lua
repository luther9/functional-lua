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
  return function()
    local function seek(iter, ...)
      if iter == nil then
        return
      end
      if f(...) then
        return filter(f, iter), ...
      end
      return seek(iter())
    end
    return seek(iter())
  end
end

local function map(f, iter)
  return function()
    return (function(iter, ...)
      if iter == nil then
        return
      end
      return map(f, iter), f(...)
    end)(iter())
  end
end

local function reduce(f, iter, init)
  return (function(iter, ...)
    if iter == nil then
      return init
    end
    return reduce(f, iter, f(init, ...))
  end)(iter())
end

local function forEach(f, iter)
  return (function(iter, ...)
    if iter ~= nil then
      f(...)
      return forEach(f, iter)
    end
  end)(iter())
end

local function fromFor(iter, state, key)
  return function()
    return (function(key, ...)
      if key == nil then
        return
      end
      return fromFor(iter, state, key), key, ...
    end)(iter(state, key))
  end
end

return {
  count = count,
  filter = filter,
  forEach = forEach,
  fromFor = fromFor,
  map = map,
  reduce = reduce,
}
