# Modules for functional programming in Lua

When finished, this project will contain modules for the following types of
sequences: arrays, tables, arguments, iterator functions, and linked lists. Each
module will contain filter, map, and reduce functions for working with those
sequences.

## Modules

* `array`: Lua's built in syntax makes this the easiest sequence type to work
  with. Drawbacks: Arrays must be mutated during construction. They can be
  slower than iterators and linked lists.

* `table`: Similar to arrays, but they can't preserve order.

* `args`: The `...` in vararg functions. While supported by Lua syntax, they can
  be more awkward to work with than arrays.

* `iterator`: A function that takes no arguments and returns the next iterator
  in the sequence and a data value. The final iterator returns nothing.  This
  sequence can be infinite. This is perhaps the most fundamental sequence type
  in functional programming.

* `list`: Linked lists. If created from an iterator, it will be lazily
  evaluated.
