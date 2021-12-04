return {
  add = function(a, b)
    return a + b
  end,
  sub = function(a, b)
    return a - b
  end,
  mul = function(a, b)
    return a * b
  end,
  div = function(a, b)
    return a / b
  end,
  mod = function(a, b)
    return a % b
  end,
  pow = function(a, b)
    return a ^ b
  end,
  unm = function(x)
    return -x
  end,
  idiv = function(a, b)
    return a // b
  end,
  band = function(a, b)
    return a & b
  end,
  bor = function(a, b)
    return a | b
  end,
  bxor = function(a, b)
    return a ~ b
  end,
  bnot = function(n)
    return ~n
  end,
  shl = function(a, b)
    return a << b
  end,
  shr = function(a, b)
    return a >> b
  end,
  concat = function(a, b)
    return a .. b
  end,
  len = function(x)
    return #x
  end,
  eq = function(a, b)
    return a == b
  end,
  lt = function(a, b)
    return a < b
  end,
  le = function(a, b)
    return a <= b
  end,
  index = function(t, k)
    return t[k]
  end,
  call = function(f, ...)
    return f(...)
  end,

  -- Operators that have no metamethods
  ne = function(a, b)
    return a ~= b
  end,
  gt = function(a, b)
    return a > b
  end,
  ge = function(a, b)
    return a >= b
  end,
  not_ = function(x)
    return not x
  end,
  and_ = function(a, b)
    return a and b
  end,
  or_ = function(a, b)
    return a or b
  end,

  -- Impure
  setIndex = function(t, k, v)
    t[k] = v
  end,
}
