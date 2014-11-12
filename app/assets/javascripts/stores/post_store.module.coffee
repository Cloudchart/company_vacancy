# Imports
#
CloudFlux = require('cloud_flux')
CallbackFactory = require('stores/callback_factory')


CrudActions = ['create', 'update', 'destroy']
CrudCallbacks = CallbackFactory.create 'post', CrudActions


DefaultMethods = 

  getSchema: ->
    uuid: ''
    title: ''
    cover_uid: null
    published_at: null
    is_published: false
    owner_type: ''
    owner_id: ''

  getActions: ->
    actions = {}

    _.each CrudActions, (action) => 
      actions["post:#{action}"] = @["handle#{_.str.titleize(action)}"]
      actions["post:#{action}:done"] = @["handle#{_.str.titleize(action)}Done"]
      actions["post:#{action}:fail"] = @["handle#{_.str.titleize(action)}Fail"]

    # actions['post:create'] = @handleCreate
    # actions['post:create:done'] = @handleCreateDone
    # actions['post:create:fail'] = @handleCreateFail

    actions

  # Create
  # 
  # handleCreate: (id, attributes, sync_token) ->
  #   @store.start_sync(id, sync_token)
  #   @store.update(id, attributes)
  #   @store.emitChange()

  # handleCreateDone: (id, attributes, json, sync_token) ->
  #   @store.stop_sync(id, sync_token)
  #   @store.reset(id)
  #   @store.add(json.uuid, json)
  #   @store.emitChange()

  # handleCreateFail: (id, attributes, json, xhr, sync_token) ->
  #   @store.stop_sync(id, sync_token)
  #   @store.add_errors(id, json.errors) if json and json.errors
  #   @store.emitChange()


# Exports
#
module.exports = CloudFlux.createStore _.extend(DefaultMethods, CrudCallbacks)
