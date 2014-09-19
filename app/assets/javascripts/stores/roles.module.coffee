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
    
    actions[Constants.Company.REVOKE_ROLE]      = @onDelete
    actions[Constants.Company.REVOKE_ROLE_DONE] = @onDeleteDone
    actions[Constants.Company.REVOKE_ROLE_FAIL] = @onDeleteFail

    actions
