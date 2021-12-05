--[[
Copyright 2021 Luther Thompson

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

local fp <const> = require'functional'

local null
local Node

-- We have to include almost all methods in List, so the user can get them as
-- standalone functions that work with both null and Node objects.

local function iota(count, start, step)
  local i <const> = start or 1
  return
    count and count < 1 and null
    or Node(
      i,
      function()
	return iota(count and count - 1, i + (step or 1), step)
      end)
end

local function fold(list, f, init)
  if list == null then
    return init
  end
  return fold(list.next, f, f(init, list[1]))
end

local function len(list)
  return fold(list, function(n) return n + 1 end, 0)
end

local function eq(a, b)
  if rawequal(a, b) then
    return true
  end
  if rawequal(a, null) or rawequal(b, null) or a[1] ~= b[1] then
    return false
  end
  return eq(a.next, b.next)
end

local function nodeLt(a, b, comp)
  local a1 <const> = a[1]
  local b1 <const> = b[1]
  if a1 < b1 then
    return true
  end
  if a1 > b1 then
    return false
  end
  return comp(a.next, b.next)
end

local function lt(a, b)
  if b == null then
    return false
  end
  if a == null then
    return true
  end
  return nodeLt(a, b, lt)
end

local function le(a, b)
  if a == null then
    return true
  end
  if b == null then
    return false
  end
  return nodeLt(a, b, le)
end

local function __concat(a, b)
  if a == null then
    return b
  end
  return Node(
    a[1],
    function()
      return a.next .. b
    end)
end

local metamethods <const> = {
  __len = len,
  __eq = eq,
  __lt = lt,
  __le = le,
  __concat = __concat,
}

local function lenEq(list, n)
  if list == null then
    return n == 0
  end
  if n < 1 then
    return false
  end
  return lenEq(list.next, n - 1)
end

local function lenLt(list, n)
  if list == null then
    return 0 < n
  end
  if n <= 1 then
    return false
  end
  return lenLt(list.next, n - 1)
end

local function lenLe(list, n)
  if list == null then
    return 0 <= n
  end
  if n < 1 then
    return false
  end
  return lenLe(list.next, n - 1)
end

local function filter(list, f)
  if list == null then
    return list
  end
  local function nextFilter()
    return filter(list.next, f)
  end
  local x <const> = list[1]
  if f(x) then
    return Node(x, nextFilter)
  end
  return nextFilter()
end

local function map(list, f)
  if list == null then
    return list
  end
  return Node(
    f(list[1]),
    function()
      return map(list.next, f)
    end)
end

local function getNext(_, node)
  local tail <const> = node.next
  if tail ~= null then
    return tail, tail[1]
  end
end

local List <const> = fp.merge(
  metamethods,
  {
    iota = iota,
    fold = fold,
    lenEq = lenEq,
    lenLt = lenLt,
    lenLe = lenLe,
    filter = filter,
    map = map,

    -- Used with for loops. Yields pairs of (node, data).
    nodes = function(list)
      return getNext, nil, Node(nil, list)
    end,

    lenNe = function(list, n)
      return not list:lenEq(n)
    end,

    lenGt = function(list, n)
      return not list:lenLe(n)
    end,

    lenGe = function(list, n)
      return not list:lenLt(n)
    end,
  })

-- The empty list. This is a singleton object. It is its own metatable.
null = fp.merge(metamethods, {__index = List})
setmetatable(null, null)
List.null = null

-- A linked list node.
Node = fp.merge(
  metamethods,
  {
    __index = function(node, key)
      if key == 1 then
	return nil
      end
      if key == 'next' then
	return node._iter()
      end
      if type(key) == 'number' and key > 1 then
	return node.next[key - 1]
      end
      return List[key]
    end,
  })
setmetatable(
  Node,
  {
    -- Return a linked list node. First argument is the data. nxt must be either
    -- a list or a function that has no parameters and returns a list.
    __call = function(cls, data, nxt)
      local node <const> = {
	data,
	[type(nxt) == 'function' and '_iter' or 'next'] = nxt,
      }
      setmetatable(node, cls)
      return node
    end,
  })
List.Node = Node

return List
