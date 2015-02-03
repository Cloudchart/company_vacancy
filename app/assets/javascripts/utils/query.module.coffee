queryRE = /^\s*([^\s]+)\s*\{([\s\S]*)\}\s*$/


# Exports
#
module.exports =

  get: (string) ->
    [dummy, model, relations] = string.match(queryRE)

    model:      model
    relations:  relations
