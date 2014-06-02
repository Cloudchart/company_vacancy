class Base

  # Following class level attributes must be defined in each class
  #
  
  # @instances: {}
  
  # @deleted_instances: []
  
  # @created_instances: []
  

  @new_form: ->
    deferred = new $.Deferred
    
    $.ajax
      url:      "#{@load_url}/new"
      type:     "GET"
      dataType: "script"
    .done (template) ->
      deferred.resolve(eval template)
    .fail ->
      deferred.reject()
    
    deferred.promise()
  

  @edit_form: (uuid) ->
    deferred = new $.Deferred
    
    $.ajax
      url:      "#{@load_url}/#{uuid}/edit"
      type:     "GET"
      dataType: "script"
    .done (template) ->
      deferred.resolve(eval template)
    .fail ->
      deferred.reject()
    
    deferred.promise()
    
  
  
  @uuid: ->
      octets      = _.map [0..32], -> Math.floor(Math.random() * 0x10)
    
      octets[12]  = (octets[12] & 0x00) | 0x04
      octets[16]  = (octets[16] & 0x03) | 0x08
    
      octets      = _.map octets, (octet) -> octet.toString(16)
    
      _.map([4, 2, 2, 2, 6], (i) -> octets.splice(0, i * 2).join('')).join('-')


  @attr_accessor: (attributes...) ->
    (@attributes ||= []).push attributes...
  
  
  @get: (uuid) -> @instances[uuid]
  
  
  @instantiate: (instances, available_uuids) ->
    self = @
    
    # Create or update provided instances
    #
    _.each instances, (attributes) ->
      if instance = self.get(attributes['uuid'])
        instance.set_attributes(attributes)
      else
        instance = new self(attributes)
      instance.synchronize()
    
    # Delete unavailable instances
    #
    _.chain(@instances)
      .reject((instance) -> _.contains(available_uuids, instance.uuid))
      .invoke('destroy')
    
    # Cleanup created instances
    #
    _.each @created_instances, (uuid) -> delete self.instances[uuid]
    @created_instances = []

    # Cleanup deleted instances
    #
    _.each @deleted_instances, (uuid) -> delete self.instances[uuid]
    @deleted_instances = []
  
  
  
  # Push
  #
  @push: (url) ->
    self = @
    deferred = new $.Deferred

    instances_to_create = _.map @created_instances, (uuid) -> self.get(uuid).attributes
    instances_to_update = _.map _.filter(@instances, (instance) -> instance.is_changed() and instance.is_persisted()), 'attributes'
    instances_to_delete = @deleted_instances
    
    if _.all([instances_to_create, instances_to_update, instances_to_delete], (collection) -> _.size(collection) == 0)
      deferred.resolve()
    else
      $.ajax
        url:  url
        type: "PUT"
        data:
          create_instances: instances_to_create
          update_instances: instances_to_update
          delete_instances: instances_to_delete
      .done ->
        deferred.resolve()
    
    deferred.promise()
  
  
  # Create
  #
  @create: (attributes = {}) ->
    instance = new @(_.extend({}, attributes, { uuid: @uuid() }))
    @created_instances.push(instance.uuid)
    instance
    

  constructor: (attributes = {}) ->
    @attributes         = {}
    @changed_attributes = {}

    @__define_accessors()

    @set_attributes(attributes)
    
    @constructor.instances[@uuid] = @ if @uuid
  
  
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
    !@synchronized_at
  

  is_persisted: ->
    !@is_new_record()
  
  
  is_deleted: ->
    _.contains @constructor.deleted_instances, @uuid
  

  is_exist: ->
    !!@constructor.get(@uuid)
  
  
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
      self.set_attribute(name, attributes[name]) if _.has(attributes, name)
    @
  
  
  update: (attributes = {}) ->
    @set_attributes(attributes)
    @
  
  
  destroy: ->
    @constructor.deleted_instances.push(@uuid)
    @
 

#
#
#

$.extend cc.blueprint.models,
  Base: Base
