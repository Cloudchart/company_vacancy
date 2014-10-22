# Imports
#
CloudFlux         = require('cloud_flux')
Constants         = require('constants')

# Exports
#
module.exports = CloudFlux.createStore


  getSiblings: (key) ->
    record    = @store.get(key)

    siblings  = @store.filter (sibling) ->
      sibling.getKey()    !=  key                 and
      sibling.owner_id    ==  record.owner_id     and
      sibling.owner_type  ==  record.owner_type   and
      sibling.position    >=  record.position
  
  
  onCreate: (key, attributes, token) ->
    @store.start_sync(key, token)
    @store.update(key, attributes)
    @store.emitChange()


  onCreateDone: (key, attributes, json, token) ->
    @store.stop_sync(key, token)
    @store.remove(key)
    _.each json.blocks, (block) => @store.add_or_update(block.uuid, block) ; @store.commit(block.uuid)
    @store.emitChange()


  onCreateFail: (key, attributes, json, xhr, token) ->
    @store.stop_sync(key, token)
    @store.add_errors(key, json.errors)
    @store.emitChange()


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
  
  
  onDestroy: (key, token) ->
    _.each @getSiblings(key), (sibling) => @store.update(sibling.getKey(), { position: sibling.position - 1 })
    @store.remove(key)
    @store.emitChange()
  

  onDestroyDone: (key, json, token) ->
    _.each json.blocks, (block) => @store.update(block.uuid, block)
    @store.emitChange()
  
  
  onDestroyFail: (key, json, xhr, token) ->
  
  
  onRepositionDone: (key, ids) ->
    _.each ids, (id) => @store.commit(id)
    @store.emitChange()


  onRepositionFail: (key, ids) ->
    _.each ids, (id) => @store.rollback(id)
    @store.emitChange()
    


  getActions: ->
    actions = {}
    
    actions['block:create']       = @onCreate
    actions['block:create:done']  = @onCreateDone
    actions['block:create:fail']  = @onCreateFail
    
    actions['block:update']       = @onUpdate
    actions['block:update:done']  = @onUpdateDone
    actions['block:update:fail']  = @onUpdateFail
    
    actions['block:destroy']      = @onDestroy
    actions['block:destroy:done'] = @onDestroyDone
    actions['block:destroy:fail'] = @onDestroyFail

    actions['blocks:reposition:done'] = @onRepositionDone
    actions['blocks:reposition:fail'] = @onRepositionFail
    
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
