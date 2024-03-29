CrudCallbacks =

  # Create
  # 
  handleCreate: (key, attributes, sync_token) ->
    @store.start_sync(key, sync_token)
    @store.update(key, attributes)
    @store.emitChange()

  handleCreateDone: (key, attributes, json, sync_token) ->
    @store.stop_sync(key, sync_token)
    @store.reset(key)
    @store.add(json.uuid, json)
    @store.emitChange()

  handleCreateFail: (key, attributes, json, xhr, sync_token) ->
    @store.stop_sync(key, sync_token)
    @store.add_errors(key, json.errors) if json and json.errors
    @store.emitChange()

  # Update
  # 
  handleUpdate: (key, attributes, sync_token) ->
    @store.start_sync(key, sync_token)
    @store.update(key, attributes)
    @store.emitChange()
  
  handleUpdateDone: (key, attributes, json, sync_token) ->
    @store.stop_sync(key, sync_token)
    @store.update(key, json)
    @store.commit(key)
    @store.emitChange()
  
  handleUpdateFail: (key, attributes, json, xhr, sync_token) ->
    @store.stop_sync(key, sync_token)
    @store.rollback(key)
    @store.emitChange()

  # Destroy
  # 
  handleDestroy: (key, sync_token) ->
    @store.start_sync(key, sync_token)
    @store.emitChange()
  
  handleDestroyDone: (key, json, sync_token) ->
    @store.stop_sync(key, sync_token)
    @store.remove(key)
    @store.emitChange()

  handleDestroyFail: (key, json, xhr, sync_token) ->
    @store.stop_sync(key, sync_token)
    @store.emitChange()


# Exports
#
exports.create = (model_name, method_names) ->

  _.inject method_names, (result, method_name) ->
    method_name = _.str.titleize(method_name)

    result["handle#{method_name}"] = CrudCallbacks["handle#{method_name}"]
    result["handle#{method_name}Done"] = CrudCallbacks["handle#{method_name}Done"]
    result["handle#{method_name}Fail"] = CrudCallbacks["handle#{method_name}Fail"]
    result
  , {}
