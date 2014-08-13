# Store Persistence
#

StorePersistence =
  

  ClassMethods:

    load: (url) ->
      $.ajax
        url:      url
        type:     'GET'
        dataType: 'json'

      .done (json) =>
        json = [json] unless _.isArray(json)
        _.each json, (attributes) =>
          model = new @(attributes)
          @add(model)
        @emitChange()
  

  InstanceMethods:
    
    create: ->
      
    update: ->
      
    destroy: ->
      

# Event Emitter
#
EventEmitter = 
  

  ClassMethods:
    

    GetElementForEmitter: ->
      @_elementForEmitter ||= document.createElement('emitter')
    

    emit: (type, detail) ->
      @GetElementForEmitter().dispatchEvent(new CustomEvent(type, { detail: detail }))
    

    on: (type, callback) ->
      @GetElementForEmitter().addEventListener(type, callback)
  

    off: (type, callback) ->
      @GetElementForEmitter().removeEventListener(type, callback)
    
    
    emitChange: ->
      @emit('change')


# Attributes
#
Attributes =
  
  InstanceMethods:
    
    _getAttributes: ->
      @_attributes ||= {}
    
    
    _getChangedAttributes: ->
      @_changedAttributes ||= {}
    

    _getAttribute: (name) ->
      @_getAttributes()[name]
    
    
    _setAttribute: (name, nextValue) ->
      if (method = @["parse_#{name}"]) and _.isFunction(method) then nextValue = method.call(@, nextValue)
      @_getAttributes()[name] = nextValue
      @
    

    attr: ->
      switch arguments.length
        
        when 0
          @_getAttributes()
        
        when 1
          if _.isObject(arguments[0])
            _.each arguments[0], (value, name) =>
              @_setAttribute(name, value)
            @
          else
            @_getAttribute(arguments[0])
        
        when 2
          [name, value] = arguments
          @_setAttribute(name, value)
          @
  
  
# Store
#

class Store
  
  
  @unique_key:  'uuid'
  @displayName: 'Store'
  

  @GetModels: ->
    @__models ||= []


  @add: (model) ->
    throw new Error("#{@displayName}.add(model): model should be instance of #{@displayName}") unless model instanceof @
    @GetModels().push(model)
  
  
  @find: (id) ->
    _.find @GetModels(), (model) -> model.to_param() == id
  
  
  constructor: (attributes) ->
    @_attributes  = {}
    @_changes     = {}
    @attr(attributes)
    @reset()
  
  
  to_param: ->
    @attr(@constructor.unique_key)
  
  
  # Clear all changes
  #
  reset: ->
    @
  
  
# Extensions
#
_.extend Store,           EventEmitter.ClassMethods
_.extend Store,           StorePersistence.ClassMethods
_.extend Store.prototype, StorePersistence.InstanceMethods
_.extend Store.prototype, Attributes.InstanceMethods

  
# Exports
#
cc.module('cc.stores.Base').exports           = Store
