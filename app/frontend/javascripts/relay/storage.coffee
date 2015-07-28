# Imports
#
Immutable   = require('immutable')


# References
#
References = Immutable.Map()


# Fetch
#
fetch = (root, params, context, query, objectType, queryType, schema) ->
  console.log arguments


# Exports
#
module.exports =

  fetch: fetch
