# Imports
#
CloudFlux   = require('cloud_flux')
Constants   = require('constants')


# Exports
#
module.exports = CloudFlux.createStore


  # onFetchDone: (json, token) ->
  #   _.each json.tags, (item) => @store.add(item.uuid, item)
  #   @store.emitChange()
  
  
  # onFetchFail: (json, xhr, token) ->
  
  
  # onCreate: (key, token) ->
  #   @store.start_sync(key)
  #   @store.update(key, { uuid: key })
  #   @store.emitChange()
  
  
  # onCreateDone: (key, json, token) ->
  #   @store.stop_sync(key)
  #   @store.remove(key)
  #   unless @store.has(json.tag.uuid)
  #     @store.add(json.tag.uuid, json.tag)
  #   @store.emitChange()
  
  
  # onCreateFail: (key, json, xhr, token) ->
  #   @store.stop_sync(key)
  #   @store.remove(key)
  #   @store.emitChange()
    


  #
  # Actions
  #
  
  # getActions: ->
  #   actions = {}
    
  #   actions[Constants.Tag.FETCH_DONE]   = @onFetchDone
  #   actions[Constants.Tag.FETCH_FAIL]   = @onFetchFail
  #   actions[Constants.Tag.CREATE]       = @onCreate
  #   actions[Constants.Tag.CREATE_DONE]  = @onCreateDone
  #   actions[Constants.Tag.CREATE_FAIL]  = @onCreateFail
    
  #   actions


  #
  # Schema
  #

  getSchema: ->
    uuid:           ''
    name:           ''
    taggins_count:  0
    is_acceptable:  false
    created_at:     null
    updated_at:     null
