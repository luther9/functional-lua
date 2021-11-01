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

local null
local Node

-- Return a linked list based on the iter function. The first node will always
-- be evaluated to determine if the list is empty.
local function fromIter(iter)
  local iter_ <const>, data <const> = iter()
  return iter_ and Node(data, iter_) or null
end

local function getNext(_, node)
  local tail <const> = node.next
  if tail ~= null then
    return tail, tail[1]
  end
end

-- Abstract base class for null and Node.
local List <const> = {
  -- Used with for loops. Yields pairs of (node, data).
  nodes = function(list)
    return getNext, nil, Node(nil, list)
  end,
}

-- The empty list. This is a singleton object. It is its own metatable.
null = {
  __index = List,

  __len = function()
    return 0
  end,

  __eq = function()
    return false
  end,

  __lt = function(a, b)
    return b ~= null
  end,

  __le = function()
    return true
  end,
}
setmetatable(null, null)

local function ltIfDifferent(a, b)
  if b == null or a[1] > b[1] then
    return false
  end
  if a[1] < b[1] then
    return true
  end
  return nil
end

-- A linked list node.
Node = {
  __index = function(node, key)
    if key == 1 then
      return nil
    end
    if key == 'next' then
      local tail <const> = fromIter(node._iter)
      node.next = tail
      node._iter = nil
      return tail
    end
    if key == math.floor(key) and key > 1 then
      return node.next[key - 1]
    end
    return Node[key]
  end,

  __len = function(node)
    return 1 + #node.next
  end,

  __eq = function(a, b)
    if b == null or a[1] ~= b[1] then
      return false
    end
    return a.next == b.next
  end,

  __lt = function(a, b)
    local comp <const> = ltIfDifferent(a, b)
    if comp ~= nil then
      return comp
    end
    return a.next < b.next
  end,

  __le == function(a, b)
    local comp <const> = ltIfDifferent(a, b)
    if comp ~= nil then
      return comp
    end
    return a.next <= b.next
  end,
}
setmetatable(
  Node,
  {
    __index = List,

    -- Return a linked list node. First argument is the data. If nxt is a
    -- function, it will be used as an iterator to lazily evaluate the rest of
    -- the list. Otherwise, nxt must be null or a Node.
    __call = function(cls, data, nxt)
      local node <const> = {
	data,
	[type(nxt) == 'function' and '_iter' or 'next'] = nxt,
      }
      setmetatable(node, cls)
      return node
    end,
  })

return {
  null = null,
  Node = Node,
  fromIter = fromIter,
}
