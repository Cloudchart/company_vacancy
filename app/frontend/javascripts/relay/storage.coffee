# Imports
#
Immutable   = require('immutable')


# References
#
References = Immutable.Map()


# Fetch
#
fetch = (root, params, query) ->
  console.log params
  console.log query


# Exports
#
module.exports =

  fetch: fetch
