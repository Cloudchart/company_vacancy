# Imports
#
CloudFlux         = require('cloud_flux')
Constants         = require('constants')

# Exports
#
module.exports = CloudFlux.createStore


  onUpdate: (key, attributes, token) ->
    @store.start_sync(key, token)
    @store.update(key, attributes)
    @store.emitChange()
  
  
  onUpdateDone: (key, json, token) ->
    @store.stop_sync(key, token)
    @store.remove(key)
    @store.add(json.paragraph.uuid, json.paragraph)
    @store.emitChange()
  
  
  onUpdateFail: (key, json, xhr, token) ->
    @stop.stop_sync(key, token)
    @store.emitChange()
  
  
  onDelete: (key, token) ->
    @store.start_sync(key, token)
    @store.emitChange()


  onDeleteDone: (key, json, token) ->
    @store.stop_sync(key, token)
    @store.remove(key)
    @store.emitChange()


  onDeleteFail: (key, json, xhr, token) ->
    @store.stop_sync(key, token)
    @store.emitChange()


  getActions: ->
    'paragraph:update':       @onUpdate
    'paragraph:update:done':  @onUpdateDone
    'paragraph:update:fail':  @onUpdateFail

    'paragraph:delete':       @onDelete
    'paragraph:delete:done':  @onDeleteDone
    'paragraph:delete:fail':  @onDeleteFail


  getSchema: ->
    uuid:           ''
    owner_type:     ''
    owner_id:       ''
    content:        ''
