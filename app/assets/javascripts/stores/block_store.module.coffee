# Imports
#
CloudFlux         = require('cloud_flux')
Constants         = require('constants')

# Exports
#
module.exports = CloudFlux.createStore


  onUpdate: (key, attributes, token) ->
    @store.update(key, attributes)
    @store.emitChange()
  
  
  onUpdateDone: (key, json, token) ->
    @store.update(key, json)
    @store.commit(key)
    @store.emitChange()


  onUpdateFail: (key, json, token) ->
    @store.rollback(key)
    @store.emitChange()


  getActions: ->
    actions = {}
    
    actions['block:update']       = @onUpdate
    actions['block:update:done']  = @onUpdateDone
    actions['block:update:fail']  = @onUpdateFail
    
    actions


  getSchema: ->
    uuid:           ''
    identity_type:  ''
    identity_ids:   []
    owner_type:     ''
    owner_id:       ''
    title:          ''
    section:        ''
    is_locked:      false
    position:       0
