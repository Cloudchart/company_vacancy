# Imports
#
CloudFlux         = require('cloud_flux')
Constants         = require('constants')

# Exports
#
module.exports = CloudFlux.createStore

  getSchema: ->
    uuid:         ''
    company_id:   ''
    name:         ''
    description:  ''
