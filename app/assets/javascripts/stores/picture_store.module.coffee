# Imports
#
CloudFlux         = require('cloud_flux')
Constants         = require('constants')

# Exports
#
module.exports = CloudFlux.createStore

  getSchema: ->
    uuid:           ''
    owner_type:     ''
    owner_id:       ''
    url:            ''
