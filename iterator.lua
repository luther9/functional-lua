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

local Iterator

-- Iterate through integers, from start to stop. The default value of start is
-- 1. If stop is nil, the iteration never ends.
local function count(start, stop)
  local i = start or 1
  return Iterator(
    function()
      if stop and i > stop then
	return
      end
      return count(i + 1, stop), i
    end)
end

local function fromFor(iter, state, key)
  return Iterator(
    function()
      local v = table.pack(iter(state, key))
      local key_ = v[1]
      if key_ == nil then
	return
      end
      return fromFor(iter, state, key_), v
    end)
end

-- All arguments must be iterators. Yield tuples of one element from each
-- iterator. Stop if any of the iterators end.
local function zip(...)
  local iters = {...}
  return Iterator(
    function()
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
    end)
end

Iterator = {
  count = count,
  fromFor = fromFor,
  zip = zip,
}

-- Helper function for the filter method.
local function seek(f, iter, v)
  if iter then
    if f(v) then
      return iter.filter(f), v
    end
    return seek(f, iter())
  end
end

setmetatable(
  Iterator,
  {
    __call = function(class, iter)
      local self

      local function filter(f)
	return class(
	  function()
	    return seek(f, self())
	  end)
      end

      local function map(f)
	return class(
	  function()
	    local iter, v = self()
	    if iter then
	      return iter.map(f), f(v)
	    end
	  end)
      end

      local function reduce(f, init)
	local iter, v = self()
	if not iter then
	  return init
	end
	return iter.reduce(f, f(init, v))
      end

      local function toFor()
	return function(_, self) return self() end, nil, self
      end

      local function forEach(f)
	for _, v in toFor() do
	  f(v)
	end
      end

      local function unpack()
	local iter, v = self()
	if iter then
	  return v, iter.unpack()
	end
      end

      self = {
	filter = filter,
	map = map,
	reduce = reduce,
	toFor = toFor,
	forEach = forEach,
	unpack = unpack,
      }

      setmetatable(
	self,
	{
	  __call = function()
	    local iter_, v = iter()
	    if iter_ then
	      return class(iter_), v
	    end
	  end,

	  __index = function(self, key)
	    if key == 'array' then
	      local a = {unpack()}
	      self.array = a
	      return a
	    end
	    return nil
	  end,
	})

      return self
    end,
  })

return Iterator
