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
  handleUpdate: (key, attributes, token) ->
    @store.start_sync(key, token)
    @store.update(key, attributes)
    @store.emitChange()
  
  handleUpdateDone: (key, json, token) ->
    @store.stop_sync(key, token)
    @store.update(key, json)
    @store.commit(key)
    @store.emitChange()
  
  handleUpdateFail: (key, json, xhr, token) ->
    @store.stop_sync(key, token)
    @store.rollback(key)
    @store.emitChange()

  # Destroy
  # 
  handleDestroy: (key, token) ->
    @store.start_sync(key, token)
    @store.emitChange()
  
  handleDestroyDone: (key, json, token) ->
    @store.stop_sync(key, token)
    @store.remove(key)
    @store.emitChange()

  handleDestroyFail: (key, json, xhr, token) ->
    @store.stop_sync(key, token)
    @store.emitChange()


# Exports
#
exports.create = (model_name, method_names) ->

  getActions = ->
    _.inject method_names, (result, method_name) =>
      titleized_method_name = _.str.titleize(method_name)

      result["#{model_name}:#{method_name}"] = @["handle#{titleized_method_name}"] 
      result["#{model_name}:#{method_name}:done"] = @["handle#{titleized_method_name}Done"]
      result["#{model_name}:#{method_name}:fail"] = @["handle#{titleized_method_name}Fail"]

      result
    , {}


  result = {}

  result['getActions'] = getActions

  _.each method_names, (method_name) ->
    method_name = _.str.titleize(method_name)

    result["handle#{method_name}"] = CrudCallbacks["handle#{method_name}"]
    result["handle#{method_name}Done"] = CrudCallbacks["handle#{method_name}Done"]
    result["handle#{method_name}Fail"] = CrudCallbacks["handle#{method_name}Fail"]

  result
