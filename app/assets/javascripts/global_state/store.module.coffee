# Imports
#
Dispatcher = require('dispatcher/dispatcher')


# Ensure
#
ensure = (something) ->
  success = !!something
  result  = 
    done: (callback) ->
      callback() if success
      result
    fail: (callback) ->
      callback() unless success
      result


# Global State accessor
#
GlobalState = -> require('global_state/state')


# Empty Sequence
#
EmptySequence = Immutable.Seq({})


# Store default
#
StoreDefaults = Immutable.Seq
  displayName:      'UndefinedStore'
  collectionName:   null
  instanceName:     null
  syncAPI:          null


# Store
#
class BaseStore
  
  
  constructor: ->
    ensure(@collectionName)
      .fail =>
        throw new Error("#{@displayName}: collectionName is undefined.")

    ensure(@instanceName)
      .fail =>
        throw new Error("#{@displayName}: instanceName is undefined.")

    @cursor =
      items: GlobalState().cursor(['stores', @collectionName, 'items'])
    
    @empty  = EmptySequence
  

  populate: (json) ->
    Immutable.Seq(json[@collectionName] || [json[@instanceName]]).forEach (item) => @cursor.items.set(item.uuid, item)
  
  
  # Fetch
  #
  
  fetchAll: (params = {}, options = {}) ->
    ensure(@syncAPI)
      .fail =>
        throw new Error("#{@displayName}: syncAPI is undefined.")

    promise = @syncAPI.fetchAll(params, options)
    promise.then(@fetchDone, @fetchFail)
    promise
  
  
  fetchOne: (id, params = {}, options = {}) ->
    ensure(@syncAPI)
      .fail =>
        throw new Error("#{@displayName}: syncAPI is undefined.")

    promise = @syncAPI.fetchOne(id, params, options)
    promise.then(@fetchDone, @fetchFail)
    promise
  
  
  fetchDone: (json) ->
    @cursor.items.transaction ->
      Dispatcher.handleServerAction
        type: 'fetch:done'
        data: [json]
  

  fetchFail: ->
  
  
  # Create
  #

  create: (params = {}, options = {}) ->
    promise = @syncAPI.create(params, options)
    promise.then(@createDone, @createFail)
    promise
  
  
  createDone: (json) ->
    @fetchOne(json.id)
  
  
  # Update
  #
  
  
  # Destroy
  #

  destroy: (id, params = {}, options = {}) ->
    currItem = @cursor.items.get(id)

    promise = @syncAPI.destroy(currItem, params, options)
    promise.then(@destroyDone, @destroyFail)
    promise
  
  
  destroyDone: (json) ->
    @cursor.items.transaction =>
      @cursor.items.remove(json.id)


# Register dispatcher
#
registerDispatcher = (store, descriptor) ->

  mappings =
    'fetch:done': store.populate


  mappings = if descriptor.serverActions instanceof Function
    Immutable.Seq(mappings).concat(descriptor.serverActions.apply(store))
      

  store.dispatchToken = Dispatcher.register (payload) ->
    type  = payload.action.type
    data  = payload.action.data
    
    if mappings.has(type)
      mappings.get(type).apply(store, data)
    

# Create
#
create = (descriptor = {}) ->
  class Store extends BaseStore

  StoreDefaults.forEach (value, name) ->
    Store.prototype[name] = descriptor[name] ? StoreDefaults[name]
    delete descriptor[name]
  

  Immutable.Seq(descriptor).forEach (value, name) ->
    Store.prototype[name] = value if value instanceof Function
  

  store = new Store
  
  Immutable.Seq(BaseStore.prototype).concat(Store.prototype).forEach (value, key) ->
    store[key] = value.bind(store) if value instanceof Function
  
  registerDispatcher(store, descriptor)
  
  store


# Exports
#
module.exports =
  Store:  BaseStore
  create: create