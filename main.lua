-- bootstrap the compiler
fennel = require("lib.fennel")
table.insert(package.loaders, fennel.make_searcher({correlate=true}))
pp = function(x) print(fennel.view(x)) end
lume = require("lib.lume")

require("game")

