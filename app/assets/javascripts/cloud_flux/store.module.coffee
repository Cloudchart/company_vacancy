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
  
  class __schm extends Immutable.Record(_.extend schema, { __key: null })
    
    constructor: (attributes = {}) ->
      super(attributes)
    
    getKey: -> @uuid || @__key
  
  
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
      __data[key] = new __schm(_.extend {}, attributes, { __key: key })
    
    
    update: (key, attributes = {}) ->
      prevRecord  = __data[key]
      __data[key] = __data[key].mergeDeep(attributes)

      (__undo[key] ||= []).push(prevRecord) ; delete __redo[key]

      __data[key]
    
    
    add_or_update: (key, attributes = {}) ->
      if @has(key) then @update(key, attributes) else @add(key, attributes)
    
    
    reset: (key) ->
      @remove(key)
      @add(key) 
    
    
    remove: (key) ->
      delete __errs[key]
      delete __data[key]
      delete __sync[key]
      delete __undo[key]
      delete __redo[key]
    
    
    add_errors: (key, errors) ->
      __errs[key] = errors


    errorsFor: (key) ->
      __errs[key]
    
    
    wait_for: (stores) ->
      Dispatcher.waitFor(_.map(stores, 'dispatchToken'))
    
    
    # Undo/Redo
    #
    undo: (key) ->
      prevRecord = if __undo[key] and __undo[key].length > 0 then __undo[key].pop()
      if prevRecord
        record = __data[key]
        (__redo[key] ||= []).push(record)
        __data[key] = record
    

    redo: (key) ->
      nextRecord = if __redo[key] and __redo[key].length > 0 then __redo[key].pop()
      if nextRecord
        record = __data[key]
        (__undo[key] ||= []).push(record)
        __data[key] = nextRecord
    

    commit: (key) ->
      delete __undo[key]
      delete __redo[key]
    
    
    rollback: (key) ->
      originalRecord = if __undo[key] and __undo[key].lenght > 0 then __undo[0]
      if originalRecord
        __data[key] = originalRecord
      @commit(key)
      
    
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
