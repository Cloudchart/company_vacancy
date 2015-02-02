queryRE = /^([^{]+)\{(.*)\}$/


# Exports
#
module.exports =

  get: (string) ->
    [_, model, relations] = string.replace(/\s+/g, '').match(queryRE)

    model:      model
    relations:  relations
