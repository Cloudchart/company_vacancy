# Base class
#
class Base
  
  @className: 'Base'

  # Following class level attributes must be defined in each class
  #
  
  # @instances: {}
  
  # @deleted_instances: []
  
  # @created_instances: []
  
  
  @broadcast_topic: -> "cc:model:#{@className.toLowerCase()}"
  

  @uuid: ->
      octets      = _.map [0..32], -> Math.floor(Math.random() * 0x10)
    
      octets[12]  = (octets[12] & 0x00) | 0x04
      octets[16]  = (octets[16] & 0x03) | 0x08
    
      octets      = _.map octets, (octet) -> octet.toString(16)
    
      _.map([4, 2, 2, 2, 6], (i) -> octets.splice(0, i * 2).join('')).join('-')



  @attr_accessor: (attributes...) ->
    (@attributes ||= []).push attributes...
  
  
  @get: (uuid) -> @instances[uuid]
  
  
  @instantiate: (instances) ->
    self = @
    
    # Create or update provided instances
    #
    _.each instances, (attributes) ->
      if instance = self.get(attributes['uuid'])
        instance.set_attributes(attributes)
      else
        instance = new self(attributes)
      instance.synchronize()
    
    # Cleanup created instances
    #
    _.each @created_instances, (uuid) -> delete self.instances[uuid]
    @created_instances = []

    # Cleanup deleted instances
    #
    _.each @deleted_instances, (uuid) -> delete self.instances[uuid]
    @deleted_instances = []
  
  
  # Load
  #
  @load: (url) ->
    @__deferreds      ||= {} ; return @__deferreds[url] if @__deferreds[url]

    @__deferreds[url]   = $.ajax
      url:        url
      type:       'GET'
      dataType:   'json'
    .done @instantiate.bind(@)
    
    @__deferreds[url].promise()
  

  # Push
  #
  @push: (url) ->
    self      = @
    deferred  = new $.Deferred

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
  
  
  can_be_deleted: ->
    @is_persisted()
  
  is_deleted: ->
    _.contains @constructor.deleted_instances, @uuid
  

  is_exist: ->
    !!@constructor.get(@uuid)
  
  
  is_synchronizing: ->
    @__is_synchronizing == true
  
  
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
  
  
  save: ->
    return if @is_synchronizing()
    
    throw "Class variable 'url' not found for #{@constructor.className} class" unless @constructor.url
      
    return unless @is_new_record() or @is_deleted() or @is_changed()
    
    @__is_synchronizing = true
    
    action = if @is_new_record()
      'create'
    else if @is_deleted()
      'delete'
    else
      'update'
    
    [ path, type ] = switch action
      when 'create'
        ['', 'POST']
      when 'update'
        ['/' + @uuid, 'PUT']
      when 'delete'
        ['/' + @uuid, 'DELETE']
        
    data = {} ; data[@constructor.className.toLowerCase()] = @attributes
    
    xhr = $.ajax
      url:    @constructor.url + path
      type:   type
      data:   data
    
    
    xhr.done (attributes) =>
      @set_attributes(attributes)
      @synchronize()
      
      
      @__is_synchronizing = false

      switch action

        when 'create'
          @constructor.created_instances.splice(@constructor.created_instances.indexOf(@uuid))

        when 'delete'
          @constructor.deleted_instances.splice(@constructor.deleted_instances.indexOf(@uuid))
          delete @constructor.instances[@uuid]

      Arbiter.publish("#{@constructor.broadcast_topic()}/#{action}")
      
    
  
  update: (attributes = {}) ->
    @set_attributes(attributes)
    @
  
  
  destroy: ->
    @constructor.deleted_instances.push(@uuid)
    @


# Expose
#
@cc.models.Base = Base