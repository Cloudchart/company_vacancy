# Imports
#
CloudFlux = require('cloud_flux')


# Exports
#
module.exports = CloudFlux.createStore


  onFetchDone: (key, json) ->
    users = json.users || []
    users.push(json.user) if json.user

    _.each users, (user) => @store.add_or_update(user.uuid, user)
    
    @store.emitChange()
  

  getActions: ->
    'company:access_rights:fetch:done': @onFetchDone
