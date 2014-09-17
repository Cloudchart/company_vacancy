# Imports
#
Dispatcher    = require('dispatcher/dispatcher')
EventEmitter  = require('utils/event_emitter')
Constants     = require('constants')
uuid          = require('utils/uuid')


# Variables
#
data      = new Immutable.Map
errors    = new Immutable.Map
syncs     = new Immutable.Map


startSync = (key, mode) ->
  syncs = syncs.set(key, mode)
  

stopSync = (key) ->
  syncs = syncs.remove(key)


# Main
#
Store =
  
  startSync: startSync
  
  stopSync: stopSync
  

  getSync: (key) ->
    syncs.get(key)
    
  
  # Create
  #
  create: ->
    key   = uuid()
    model = new Immutable.Map
    data  = data.set(key, model)
    key
  
  
  # Errors
  #
  getErrors: (key) ->
    errors.get(key)
  
  
  # Has
  #
  has: (key) ->
    data.has(key)
  
  
  # Get
  #
  get: (key) ->
    data.get(key)
  
  
  # Get key
  #
  getKey: (model) ->
    data.findKey(model)
  
  
  # Find
  #
  filter: (predicate) ->
    data.filter(predicate)
  
  
  # Add
  #
  add: (attributes = {}) ->
    data  = data.set(attributes.uuid, Immutable.fromJS(attributes))
  
  
  # Update
  #
  update: (key, attributes = {}) ->
    model = data.get(key).mergeDeep(attributes)
    data  = data.set(key, model)
  
  
  # Add or Update
  #
  add_or_update: (attributes = {}) ->
    key = attributes.uuid
    if data.get(key)
      @update(key, attributes)
    else
      @add(attributes)
  
  
  # Remove
  #
  remove: (key) ->
    data    = data.remove(key)
    errors  = errors.remove(key)
    key
  

# Event Emitter
#
_.extend Store, EventEmitter


# Dispatching
#
Store.dispatchToken = Dispatcher.register (payload) ->
  action = payload.action      

  switch action.type
    
    when Constants.Token.FETCH_DONE
      json = if _.isArray(action.json) then action.json else [action.json]
      _.each json, (attributes) -> Store.add_or_update(attributes)
      Store.emitChange()
      

    when Constants.Token.CREATE
      startSync(action.key, 'create')
      Store.update(action.key, action.attributes)
      Store.emitChange()
    
    
    when Constants.Token.CREATE_DONE
      stopSync(action.key, 'create')
      Store.remove(action.key)
      Store.add(action.json)
      Store.emitChange()
    
    
    when Constants.Token.CREATE_FAIL
      stopSync(action.key, 'create')
      errors = errors.set(action.key, Immutable.fromJS(action.json.errors))
      Store.emitChange()
    
    
    when Constants.Token.UPDATE
      startSync(action.key, 'update')
      Store.update(action.key, action.attributes)
      Store.emitChange()
    
    
    when Constants.Token.UPDATE_DONE
      stopSync(action.key, 'update')
      #Store.update(action.key, action.attributes)
      Store.emitChange()
    
    
    when Constants.Token.UPDATE_FAIL
      stopSync(action.key, 'update')
      #Store.update(action.key, action.attributes)
      Store.emitChange()
    
    
    when Constants.Token.DELETE
      startSync(action.key, 'delete')
      Store.emitChange()


    when Constants.Token.DELETE_DONE
      stopSync(action.key, 'delete')
      Store.remove(action.key)
      Store.emitChange()


# Exports
#
module.exports = Store
