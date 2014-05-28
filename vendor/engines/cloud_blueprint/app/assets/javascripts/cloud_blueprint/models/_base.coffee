class Base

  # Following class level attributes must be defined in each class
  #
  
  # @attributes: []
  
  # @instances: {}
  
  # @deleted_instances: []
  
  # @created_instances: []
  
  
  @attr_accessor: (attributes...) ->
    @attributes.push(attributes...)
  
  
  @get: (uuid) -> @instances[uuid]
  
  
  @instantiate: (instances, available_uuids) ->
    self = @

    _.each instances, (attributes) ->
      if instance = self.get(attributes['uuid'])
        instance.set_attributes(attributes)
      else
        instance = new self(attribute)
      instance.synchronize()
    
    _.chain(@instances)
      .reject(
        (instance) -> _.contains(available_uuids, instance.uuid)
      )
      .invoke('destroy')
    
    _.each @created_instances, (uuid) -> self.get(uuid).destroy()
    @created_instances = []
    
    _.each @deleted_instances, (uuid) -> self.get(uuid).destroy()
    @deleted_instances = []
  
  
  constructor: (attributes = {}) ->
    @attributes         = {}
    @changed_attributes = {}

    @__define_accessors()

    @set_attributes(attributes)
    
    @constructor.instances[@uuid] = @
  
  
  __define_accessors: ->
    self = @
    
    _.each @constructor.attributes, (name) ->
      Object.defineProperty self, name,
        get: ->
          self.get_attribute(name)
        set: (value) ->
          self.set_attribute(name, value)
  
  
  synchronize: ->
    @changed_attributes = {}
    @synchronized_at = new Date
    @
  

  touch: ->
    @updated_at = new Date
    @
  

  is_changed: ->
    @updated_at > @synchronized_at or _.size(@changed_attributes) > 0
  
  
  is_new_record: ->
    !!@constructor.created_instances[@uuid]
  

  is_persisted: ->
    !@is_new_record()
  
  
  is_deleted: ->
    !!@cunstructor.deleted_instances[@uuid]
  
  
  get_attribute: (name) ->
    if _.isFunction(@["get_#{name}"])
      @["get_#{name}"]()
    else
      @attributes[name]
  

  set_attribute: (name, value) ->
    previous_value = @get_attribute(name)
    
    unless value == previous_value
      (@changed_attributes[name] ||= []).push(previous_value)

      if _.isFunction(@["set_#{name}"])
        @["set_#{name}"](name, value)
      else
        @attributes[name] = value

      @updated_at = new Date
    
    @get_attribute(name)
  
  
  set_attributes: (attributes = {}) ->
    self = @
    _.each @constructor.attributes, (name) ->
      self.set_attribute(name, attributes[name]) if _.has(sttributes, name)
    @


#
#
#

$.extend cc.blueprint.models,
  Base: Base
