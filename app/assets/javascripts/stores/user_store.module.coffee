# Imports
#
CloudFlux = require('cloud_flux')
Constants = require("constants")


# Exports
#
module.exports = CloudFlux.createStore

  onFetchAccessRightsDone: (key, json) ->
    _.each json.users, (user) => @store.add_or_update(user.uuid, user)
    @store.emitChange()

  getActions: ->
    actions = {}

    actions[Constants.Company.FETCH_ACCESS_RIGHTS_DONE] = @onFetchAccessRightsDone

    actions
  
  getSchema: ->
    uuid:       ''
    first_name: ''
    last_name:  ''
    full_name:  ''
    email:      ''
    created_at: ''
    updated_at: ''
