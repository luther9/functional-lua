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

  __call = function(self)
    return self._f()
  end,

  -- Yield only the elements where f(element) is truthy.
  filter = function(self, f)
    local function seek(iter, v)
      if iter then
	if f(v) then
	  return iter:filter(f), v
	end
	return seek(iter())
      end
    end
    return Iterator(
      function()
	return seek(self())
      end)
  end,

  -- Make a new iterator where f is applied to each element.
  map = function(self, f)
    return Iterator(
      function()
	local iter, v = self()
	if iter then
	  return iter:map(f), f(v)
	end
      end)
  end,

  -- Combine all elements of the iterator into a single value. init is the
  -- seed value. f is called as f(init, element) for each element.
  reduce = function(self, f, init)
    local iter, v = self()
    if not iter then
      return init
    end
    return iter:reduce(f, f(init, v))
  end,

  -- Convert the iterator for use in a for loop. The resulting iterator will
  -- yield the same function and value as an Iterator object. The function
  -- result should usually be ignored in the loop body.
  toFor = function(self)
    return function(_, self) return self() end, nil, self
  end,

  -- Execute f(element) for each element in the iterator.
  forEach = function(self, f)
    for _, v in self:toFor() do
      f(v)
    end
  end,

  -- Return all elements from the iterator.
  unpack = function(self)
    local iter, v = self()
    if iter then
      return v, iter:unpack()
    end
  end,

  -- Convert the iterator to an array.
  array = function(self)
    return {self:unpack()}
  end,

  -- Assuming all elements are numbers, return the sum.
  sum = function(self)
    return self:reduce(function(a, b) return a + b end, 0)
  end,

  -- Assuming all elements are numbers, return the product.
  product = function(self)
    return self:reduce(function(a, b) return a * b end, 1)
  end,

  -- Assuming all elements are strings, concatenate them all.
  concat = function(self)
    return self:reduce(function(a, b) return a .. b end, '')
  end,
}
Iterator.__index = Iterator

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
      local self = {_f = iter}
      setmetatable(self, class)
      return self
    end,
  })

return Iterator
