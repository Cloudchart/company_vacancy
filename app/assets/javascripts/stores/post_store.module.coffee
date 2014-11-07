# Imports
#
CloudFlux         = require('cloud_flux')
Constants         = require('constants')

# Exports
#
module.exports = CloudFlux.createStore

  # TODO: write base CRUD, something like only: [:create, :update, :destroy]

  onCreate: (key, attributes, token) ->
    @store.start_sync(key, token)
    @store.update(key, attributes)
    @store.emitChange()

  onCreateDone: (key, attributes, json, token) ->
    @store.stop_sync(key, token)
    @store.reset(key)
    @store.add(json.uuid, json)
    @store.emitChange()

  onCreateFail: (key, attributes, json, xhr, token) ->
    @store.stop_sync(key, token)
    @store.add_errors(key, json.errors) if json and json.errors
    @store.emitChange()


  onUpdate: (key, attributes, token) ->
    @store.start_sync(key, token)
    @store.update(key, attributes)
    @store.emitChange()
  
  onUpdateDone: (key, json, token) ->
    @store.stop_sync(key, token)
    @store.update(key, json)
    @store.commit(key)
    @store.emitChange()
  
  onUpdateFail: (key, json, xhr, token) ->
    @store.stop_sync(key, token)
    @store.rollback(key)
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
  

  getSchema: ->
    uuid: ''
    title: ''
    cover_uid: null
    published_at: null
    owner_type: ''
    owner_id: ''

  getActions: ->
    'post:create':       @onCreate
    'post:create:done':  @onCreateDone
    'post:create:fail':  @onCreateFail
    'post:update':       @onUpdate
    'post:update:done':  @onUpdateDone
    'post:update:fail':  @onUpdateFail
    'post:destroy':      @onDestroy
    'post:destroy:done': @onDestroyDone
    'post:destroy:fail': @onDestroyFail

