local function fold(t, f, init)
  local function h(init, i)
    local v <const> = t[i]
    if v == nil then
      return init
    end
    return h(f(init, v), i + 1)
  end
  return h(init, 1)
end

-- Copy the contents of all arguments into a single merged table. Keys and
-- metatable of later arguments will overwrite earlier ones.
local function merge(...)
  local args <const> = {...}
  local t <const> = {}
  for _, arg in ipairs(args) do
    for k, v in pairs(arg) do
      t[k] = v
    end
  end
  setmetatable(
    t,
    fold(
      args,
      function(mt, t) 
	local newMt <const> = getmetatable(t)
	return type(newMt) == 'table' and newMt or mt
      end))
  return t
end
