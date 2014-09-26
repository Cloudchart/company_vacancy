# Imports
#
Dispatcher    = require('dispatcher/dispatcher')
EventEmitter  = require('utils/event_emitter')
uuid          = require('utils/uuid')

# Factory
#
Factory = (definition) ->
  

  # Data
  #
  __data  = {}
  __sync  = {}
  __errs  = {}
  __undo  = {}
  __redo  = {}
  
  
  # Get Schema
  #
  schema = if _.isFunction(definition.getSchema) then definition.getSchema() else null
  throw new Error("Store #{definition.displayName}: getSchema should be defined.") unless schema
  

  # Define schema
  #
  class __schm extends Immutable.Record(schema)
  
  
  # Get Actions
  #
  actions = if _.isFunction(definition.getActions) then definition.getActions() else {}
  
  
  # Parse Attributes
  #
  parseAttributes = _.identity
  

  # Store definition
  #
  Store =
    

    create: (attributes = {}) ->
      key = uuid()
      @add(key, attributes)
      key
    

    all: ->
      _.values(__data)
    

    get: (key) ->
      record = __data[key]
      record
    

    has: (key) ->
      _.has(__data, key)
    
    
    find: (predicate) ->
      _.find __data, predicate.bind(definition)
    
    
    filter: (predicate) ->
      _.filter __data, predicate.bind(definition)
    
    
    add: (key, attributes = {}) ->
      __data[key] = new __schm(attributes)
    
    
    update: (key, attributes = {}) ->
      __data[key] = __data[key].mergeDeep(attributes)
    
    
    add_or_update: (key, attributes = {}) ->
      if @has(key) then @update(key, attributes) else @add(key, attributes)
    
    
    remove: (key) ->
      delete __errs[key]
      delete __data[key]
    
    
    add_errors: (key, errors) ->
      __errs[key] = errors


    errorsFor: (key) ->
      __errs[key]
    
    
    wait_for: (stores) ->
      Dispatcher.waitFor(_.map(stores, 'dispatchToken'))
      
    
    # Sync
    #
    start_sync: (key, token) ->
      return @start_sync('base', key) if arguments.length < 2
      __sync[key] = token
    
    
    stop_sync: (key) ->
      return @stop_sync('base', key) if arguments.length < 1
      delete __sync[key]
    

    is_in_sync: (key) ->
      return @is_in_sync('base') if arguments.length < 1
      _.has(__sync, key)
    
    
    getSync: (key = 'base') -> __sync[key]
  
  
  # Event emitter
  #
  _.extend Store, EventEmitter ; Store.GetElementForEmitter()
  

  # Register dispatchers
  #
  Store.dispatchToken = Dispatcher.register (payload) ->
    if _.has(actions, payload.action.type)
      actions[payload.action.type].apply(definition, payload.action.data)
  

  # Set store
  #
  definition.store = Store
  

  # Freeze store
  #
  Object.freeze(Store)
  

  # Return store
  #
  Store


# Exports
#
module.exports = Factory