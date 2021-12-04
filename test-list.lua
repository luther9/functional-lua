local List <const> = require'list'

local lst <const> = List.Node(42, List.null)

assert(lst:map(function(x) return x * 2 end)[1] == 84)
