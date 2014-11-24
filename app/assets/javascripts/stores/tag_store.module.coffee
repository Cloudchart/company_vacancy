# Imports
#
CloudFlux   = require('cloud_flux')
Constants   = require('constants')

# Exports
#
module.exports = CloudFlux.createStore

  #
  # Schema
  #

  getSchema: ->
    uuid:           ''
    name:           ''
    taggins_count:  0
    is_acceptable:  false
    created_at:     null
    updated_at:     null
