# Imports
#
CloudFlux         = require('cloud_flux')
AccessRightsStore = require('stores/company_access_rights')
UsersStore        = require('stores/users')


# Exports
#
module.exports = CloudFlux.createStore


  onAccessRightsFetchDone: ->
    @store.waitFor([AccessRightsStore, UsersStore])
    @store.emitChange()
  

  getActions: ->
    'company:access_rights:fetch:done': @onAccessRightsFetchDone
