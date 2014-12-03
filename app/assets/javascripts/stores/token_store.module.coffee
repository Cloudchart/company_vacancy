# Imports
#
CloudFlux   = require('cloud_flux')
Constants   = require('constants')

# Exports
#
module.exports = CloudFlux.createStore


  #
  # Fetch
  #


  onFetchInviteTokensDone: (key, json) ->
    _.each json.tokens, (item) => @store.add_or_update(item.uuid, item)
    @store.emitChange()
  

  #
  # Create
  #
  

  onCreate: (key, attributes, token = 'create') ->
    @store.start_sync(key, token)
    @store.update(key, attributes)
    @store.emitChange()
  
  
  onCreateDone: (key, json, token = 'create') ->
    @store.stop_sync(key, token)
    @store.remove(key)
    @store.add(json.token.uuid, json.token)
    @store.emitChange()
  
  
  onCreateFail: (key, json, xhr, token = 'create') ->
    @store.stop_sync(key, token)
    if json
      @store.add_errors(key, json.errors || json.token.errors)
    else
      @store.add_errors(key, { server: xhr.status })
    @store.emitChange()
  

  #
  # Update
  #
  

  onUpdate: (key, attributes, token = 'update') ->
    @store.start_sync(key, token)
    @store.update(key, attributes)
    @store.emitChange()


  onUpdateDone: (key, json, token = 'update') ->
    @store.stop_sync(key, token)
    @store.emitChange()


  onUpdateFail: (key, json, xhr, token = 'update') ->
    @store.stop_sync(key, token)
    if json
      @store.add_errors(key, json.errors || json.token.errors)
    else
      @store.add_errors(key, { server: xhr.status })
    @store.emitChange()
  

  #
  # Delete
  #
  
  onDelete: (key, token = 'delete') ->
    @store.start_sync(key, token)
    @store.emitChange()
  

  onDeleteDone: (key, json, token = 'delete') ->
    @store.stop_sync(key, token)
    @store.remove(key)
    @store.emitChange()
  
  
  onDeleteFail: (key, json, xhr, token = 'delete') ->
    @store.stop_sync(key, token)
    if json
      @store.add_errors(key, json.errors || json.token.errors)
    else
      @store.add_errors(key, { server: xhr.status })
    @store.emitChange()
  
  
  #
  # Actions
  #
  
  getActions: ->
    actions = {}
    
    actions[Constants.Company.FETCH_INVITE_TOKENS_DONE] = @onFetchInviteTokensDone

    actions[Constants.Token.CREATE]       = @onCreate
    actions[Constants.Token.CREATE_DONE]  = @onCreateDone
    actions[Constants.Token.CREATE_FAIL]  = @onCreateFail

    actions[Constants.Token.UPDATE]       = @onUpdate
    actions[Constants.Token.UPDATE_DONE]  = @onUpdateDone
    actions[Constants.Token.UPDATE_FAIL]  = @onUpdateFail

    actions[Constants.Token.DELETE]       = @onDelete
    actions[Constants.Token.DELETE_DONE]  = @onDeleteDone
    actions[Constants.Token.DELETE_FAIL]  = @onDeleteFail

    actions

  
  #
  # Schema
  #

  getSchema: ->
    uuid:       ''
    name:       ''
    data:       {}
    owner_id:   ''
    owner_type: ''
    created_at: ''
    updated_at: ''
