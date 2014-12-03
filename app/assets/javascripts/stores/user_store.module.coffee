# Imports
#
CloudFlux = require('cloud_flux')


# Exports
#
module.exports = CloudFlux.createStore
  
  getSchema: ->
    uuid:       ''
    first_name: ''
    last_name:  ''
    full_name:  ''
    email:      ''
    created_at: ''
    updated_at: ''
