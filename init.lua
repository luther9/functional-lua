-- Miscelleneous utilities for functional programming.

local function identity(...)
  return ...
end

local function merge(...)
  local result <const> = {}
  for _, t in ipairs{...} do
    for k, v in pairs(t) do
      result[k] = v
    end
  end
  return result
end

return {
  identity = identity,
  merge = merge,
}
