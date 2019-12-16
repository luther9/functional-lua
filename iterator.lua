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

-- The Iterator class. The argument is an iterator function.
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

-- Convert a for loop iterator to an Iterator object.
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

local function checkCallable(f)
  local fType = type(f)
  if fType ~= 'function' then
    local mt = getmetatable(iter)
    if not mt or type(mt.__call) ~= 'function' then
      error('Expected function, got ' .. fType, 3)
    end
  end
end

setmetatable(
  Iterator,
  {
    __call = function(class, iter)
      checkCallable(iter)

      local self

      -- Yield only the elements where f(element) is truthy.
      local function filter(f)
	return class(
	  function()
	    return seek(f, self())
	  end)
      end

      -- Make a new element where f is applied to each element.
      local function map(f)
	return class(
	  function()
	    local iter, v = self()
	    if iter then
	      return iter.map(f), f(v)
	    end
	  end)
      end

      -- Combine all elements of the iterator into a single value. init is the
      -- seed value. f is called as f(init, element) for each element.
      local function reduce(f, init)
	local iter, v = self()
	if not iter then
	  return init
	end
	return iter.reduce(f, f(init, v))
      end

      -- Convert the iterator for use in a for loop. The resulting iterator will
      -- yield the same function and value as an Iterator object. The function
      -- result should usually be ignored in the loop body.
      local function toFor()
	return function(_, self) return self() end, nil, self
      end

      -- Execute f(element) for each element in the iterator.
      local function forEach(f)
	for _, v in toFor() do
	  f(v)
	end
      end

      -- Return all elements from the iterator.
      local function unpack()
	local iter, v = self()
	if iter then
	  return v, iter.unpack()
	end
      end

      -- A method version of Iterator.zip.
      local function zip(...)
	return Iterator.zip(self, ...)
      end

      self = {
	filter = filter,
	map = map,
	reduce = reduce,
	toFor = toFor,
	forEach = forEach,
	unpack = unpack,
	zip = zip,
      }

      -- Cached fields
      local fields = {
	-- Convert the iterator to an array. We can't return an Array object,
	-- because that would require a circular dependency.
	array = function()
	  return {unpack()}
	end,

	-- Assuming all elements are numbers, return the sum.
	sum = function()
	  return reduce(function(a, b) return a + b end, 0)
	end,

	-- Assuming all elements are numbers, return the product.
	product = function()
	  return reduce(function(a, b) return a * b end, 1)
	end,

	-- Assuming all elements are strings, concatenate them all.
	concat = function()
	  return reduce(function(a, b) return a .. b end, '')
	end,
      }

      setmetatable(
	self,
	{
	  __call = function()
	    return iter()
	  end,

	  -- If key is in fields, call that function, cache the result and
	  -- return it.
	  __index = function(self, key)
	    local f = fields[key]
	    if not f then
	      return nil
	    end
	    local v = f()
	    self[key] = v
	    return v
	  end,
	})

      return self
    end,
  })

return Iterator
