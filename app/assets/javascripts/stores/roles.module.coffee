# Imports
#
CloudFlux = require('cloud_flux')
Constants = require('constants')


# Exports
#
module.exports = CloudFlux.createStore


  onAccessRightsFetchDone: (key, json) ->
    _.each (json.roles), (props) => @store.add_or_update(props.uuid, props)
    @store.emitChange()
  
  
  onDelete: (key, token = 'delete') ->
    @store.start_sync(key, token)
    @store.emitChange()
  
  onDeleteDone: (key, json, token = 'delete') ->
    @store.remove(key)
    @store.stop_sync(key, token)
    @store.emitChange()
  
  onDeleteFail: (key, json, xhr, token = 'delete') ->
    @store.stop_sync(key, token)
    @store.emitChange()
    
  onUpdate: (key, attributes, token = 'delete') ->
    @store.start_sync(key, token)
    @store.update(key, attributes)
    @store.emitChange()
  
  onUpdateDone: (key, json, token = 'delete') ->
    @store.stop_sync(key, token)
    @store.update(key, json)
    # @store.commit(key)
    @store.emitChange()
  
  onUpdateFail: (key, json, xhr, token = 'delete') ->
    @store.stop_sync(key, token)
    # @store.undo(key)
    @store.emitChange()

  onCreate: (key, attributes, sync_token = 'create') ->
    @store.start_sync(key, sync_token)
    @store.emitChange()
    
  onCreateDone: (key, json, sync_token = 'create') ->
    @store.stop_sync(key, sync_token)
    @store.add(json.role.uuid, json.role)
    @store.emitChange()
  
    # TODO: need to update company because of new role, ask seanchas about good place for it
    # also need to update favorites store

  onCreateFail: (key, json, xhr, sync_token = 'create') ->
    @store.stop_sync(key, sync_token)
    if json
      @store.add_errors(key, json.errors || json.role.errors)
    else
      @store.add_errors(key, { server: xhr.status })
    @store.emitChange()

  
  getSchema: ->
    uuid:       ''
    value:      ''
    user_id:    ''
    owner_id:   ''
    owner_type: ''
    created_at: ''
    updated_at: ''


  getActions: ->
    actions = {}
    
    actions['company:access_rights:fetch:done'] = @onAccessRightsFetchDone
    
    actions[Constants.Role.DELETE]      = @onDelete
    actions[Constants.Role.DELETE_DONE] = @onDeleteDone
    actions[Constants.Role.DELETE_FAIL] = @onDeleteFail

    actions[Constants.Role.UPDATE]      = @onUpdate
    actions[Constants.Role.UPDATE_DONE] = @onUpdateDone
    actions[Constants.Role.UPDATE_FAIL] = @onUpdateFail

    actions[Constants.Role.CREATE]       = @onCreate
    actions[Constants.Role.CREATE_DONE]  = @onCreateDone
    actions[Constants.Role.CREATE_FAIL]  = @onCreateFail

    actions
