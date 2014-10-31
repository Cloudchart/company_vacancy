# Imports
#
CloudFlux         = require('cloud_flux')
Constants         = require('constants')

# Exports
#
module.exports = CloudFlux.createStore

  # onUpdate: (key, attributes, token) ->
  #   @store.start_sync(key, token)
  #   @store.update(key, attributes)
  #   @store.emitChange()
  
  # onUpdateDone: (key, json, token) ->
  #   @store.stop_sync(key, token)
  #   @store.update(key, json)
  #   @store.commit(key)
  #   @store.emitChange()
  
  # onUpdateFail: (key, json, xhr, token) ->
  #   @store.stop_sync(key, token)
  #   @store.rollback(key)
  #   @store.emitChange()
  
  getSchema: ->
    uuid: ''
    title: ''
    cover_uid: null
    published_at: null

  getActions: ->
    actions = {}

    # actions[Constants.Post.UPDATE]       = @onUpdate
    # actions[Constants.Post.UPDATE_DONE]  = @onUpdateDone
    # actions[Constants.Post.UPDATE_FAIL]  = @onUpdateFail

    actions
