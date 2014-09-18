# Imports
#
Dispatcher    = require('dispatcher/dispatcher')
EventEmitter  = require('utils/event_emitter')

# Factory
#
Factory = (definition) ->
  

  # Data
  #
  __data  = {}
  __sync  = {}
  __errs  = {}
  __schm  = null
  

  # Get Actions
  #
  actions = if _.isFunction(definition.getActions) then definition.getActions() else {}
  
  
  # Get Schema
  #
  schema = if _.isFunction(definition.getSchema) then definition.getSchema()
  
  
  # Parse Attributes
  #
  parseAttributes = _.identity
  

  # Store definition
  #
  Store =
    
    all: ->
      _.values(__data)
    

    get: (key) ->
      __data[key]
    

    has: (key) ->
      _.has(__data, key)
    
    
    find: (predicate) ->
      _.find __data, predicate.bind(definition)
    
    
    filter: (predicate) ->
      _.filter __data, predicate.bind(definition)
    
    
    add: (key, attributes = {}) ->
      attributes = parseAttributes(attributes)
      __data[key] = (if __schm then new __schm(attributes) else attributes)
    
    
    update: (key, attributes = {}) ->
      attributes = parseAttributes(attributes)
      __data[key] = __data[key].merge(attributes)
    
    
    add_or_update: (key, attributes = {}) ->
      if @has(key) then @update(key, attributes) else @add(key, attributes)
    
    
    remove: (key) ->
      delete __data[key]
    
    
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
  
  
  # Event emitter
  #
  _.extend Store, EventEmitter ; Store.GetElementForEmitter()
  

  if schema
    attributes = _.reduce schema, (memo, value, key) ->
      memo[key] = value.default || value || null
      memo
    , {}
    __schm = Immutable.Record(attributes)
  

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
