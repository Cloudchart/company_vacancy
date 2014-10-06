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
    full_name:    ''
    first_name:   ''
    last_name:    ''
    occupation:   ''
