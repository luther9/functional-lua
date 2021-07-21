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

-- It's debatable whether arrays or iterators are more fundemental, so neither
-- one will depend on the other.

local function iterator(self, i)
  return function()
    local value = self[i]
    if value == nil then
      return
    end
    return iterator(self, i + 1), {i, value}
  end
end

local Array

Array = {
  -- Class method. Copy array elements from t into a new Array object.
  copy = function(t)
    return Array(table.unpack(t))
  end,

  iterator = function(self)
    return iterator(self, 1)
  end,
}
Array.__index = Array

setmetatable(
  Array,
  {
    -- Put arguments into a new Array.
    __call = function(class, ...)
      local self = {...}
      setmetatable(self, class)
      return self
    end,
  })

return Array
