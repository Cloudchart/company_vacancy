# Imports
#
CloudFlux   = require('cloud_flux')
Constants   = require('constants')

# Exports
#
module.exports = CloudFlux.createStore

  onRoleCreateDone: (key, json, sync_token) ->
    if sync_token == 'accept_invite' and json.favorite
      @store.remove(json.favorite.uuid)
      @store.emitChange()

  
  #
  # Actions
  #
  
  getActions: ->
    actions = {}

    actions[Constants.Role.CREATE_DONE]  = @onRoleCreateDone

    actions

  
  #
  # Schema
  #

  getSchema: ->
    uuid:             ''
    favoritable_id:   ''
