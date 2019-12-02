This code uses a functional programming style.

Since Lua supports proper tail calls, `while` loops are not allowed. `for` loops
are allowed, because they can act as a replacement for a forEach function.

We do not assign to any variable after declaration.

The following operations are fundamental for table construction, and are
therefore allowed: key assignment, `setmetatable`, `table.insert`, and
`table.move`. `table.sort` is also allowed for performance reasons.

Objects may be mutated internally for caching and lazy evaluation. Users
should treat them as immutable.
