This code uses a functional programming style.

Since Lua supports proper tail calls, `while` loops are not allowed. `for` loops
are allowed, because they can act as a replacement for a forEach function.

We do not assign to any variable after declaration.

The following operations are fundamental for table construction, and are
therefore allowed: key assignment, `setmetatable`, `table.insert`, and
`table.move`. `table.sort` is also allowed for performance reasons.

Linked lists may be mutated internally to implement lazy evaluation. Users
should treat them as immutable.

Each module treats its own sequence type as the most fundamental sequence type
in Lua.
