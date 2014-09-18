# Imports
#
CloudFlux = require('cloud_flux')


# Exports
#
module.exports = CloudFlux.createStore


  onAccessRightsFetchDone: (key, json) ->
    _.each json.users, (user) => @store.add_or_update(user.uuid, user)
    @store.emitChange()
  

  getActions: ->
    'company:access_rights:fetch:done': @onAccessRightsFetchDone
