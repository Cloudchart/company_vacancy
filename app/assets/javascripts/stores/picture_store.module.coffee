# Imports
#
CloudFlux         = require('cloud_flux')
Constants         = require('constants')

# Exports
#
module.exports = CloudFlux.createStore


  onCreate: (key, attributes, token) ->
    @store.start_sync(key, token)
    @store.emitChange()
  
  
  onCreateDone: (key, json, token) ->
    @store.stop_sync(key, token)
    @store.remove(key)
    @store.add(json.picture.uuid, json.picture)
    @store.emitChange()
  
  
  onCreateFail: ->
    @store.stop_sync(key, token)
    @store.emitChange()
  
  
  onUpdate: (key, token) ->
    @store.start_sync(key, token)
    @store.emitChange()
  
  
  onUpdateDone: (key, json, token) ->
    @store.stop_sync(key, token)
    @store.update(key, json.picture)
    @store.emitChange()


  onUpdateFail: (key, json, xhr, token) ->
    @store.stop_sync(key, token)
    @store.emitChange()


  onDestroy: (key, token) ->
    @store.start_sync(key, token)
    @store.emitChange()
  
  
  onDestroyDone: (key, json, token) ->
    @store.stop_sync(key, token)
    @store.remove(key)
    @store.emitChange()


  onDestroyFail: (key, json, xhr, token) ->
    @store.stop_sync(key, token)
    @store.emitChange()


  getActions: ->
    actions = {}
    
    actions['picture:create']       = @onCreate
    actions['picture:create:done']  = @onCreateDone
    actions['picture:create:fail']  = @onCreateFail

    actions['picture:update']       = @onUpdate
    actions['picture:update:done']  = @onUpdateDone
    actions['picture:update:fail']  = @onUpdateFail

    actions['picture:destroy']       = @onDestroy
    actions['picture:destroy:done']  = @onDestroyDone
    actions['picture:destroy:fail']  = @onDestroyFail
    
    actions


  getSchema: ->
    uuid:           ''
    owner_type:     ''
    owner_id:       ''
    url:            ''
