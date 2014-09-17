# Imports
#
Dispatcher    = require('dispatcher/dispatcher')
EventEmitter  = require('utils/event_emitter')
Constants     = require('constants')
uuid          = require('utils/uuid')


# Variables
#
data    = new Immutable.Map
errors  = new Immutable.Map


# Main
#
Store =
  
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
  
  
  # Get
  #
  get: (key) ->
    data.get(key).toJS()
  
  
  # Get key
  #
  getKey: (model) ->
    data.findKey(model)
  
  
  # Find
  #
  filter: (predicate) ->
    data.filter(predicate).toVector().toJS()
  
  
  # Add
  #
  add: (attributes = {}) ->
    data  = data.set(attributes.uuid, Immutable.fromJS(attributes))
  
  
  # Update
  #
  update: (key, attributes = {}) ->
    model = data.get(key).merge(attributes)
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
    data = data.remove(key)
  

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
      Store.update(action.key, action.attributes)
      Store.emitChange()
    
    
    when Constants.Token.CREATE_DONE
      Store.remove(action.key)
      Store.add(action.json)
      Store.emitChange()
    
    
    when Constants.Token.CREATE_FAIL
      Store.emitChange()
    
    
    when Constants.Token.DELETE_DONE
      Store.remove(action.key)
      Store.emitChange()


# Exports
#
module.exports = Store
