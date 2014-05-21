@cc                    ?= {}
@cc.blueprint          ?= {}
@cc.blueprint.models   ?= {}

#
#
#

class Base
  
  @attr_accessor: (attributes...) ->
    @attributes = attributes
  

  @load: ->
    self = @

    $.ajax
      url:      @load_url
      type:     'GET'
      dataType: 'json'
    
    .done (data) ->
      _.each data, (attributes) -> self.find_or_create(attributes)
      Arbiter.publish("#{self.topic}/load", self.instances)
    
    .fail ->
      # pass
  

  @instantiate: (attributes = {}) ->
    instance  = @instances[attributes.uuid] || new @(attributes)
    instance.set_attributes(attributes)
    instance
    

  constructor: (attributes = {}) ->
    @set_accessors()
    @set_attributes(attributes)

    @__changed                    = false
    @constructor.instances[@uuid] = @

    Arbiter.publish("#{@constructor.topic}/new", @)
  
  
  changed: ->
    @__changed
  
  
  set_accessors: () ->
    self        = @
    @attributes = {}

    _.each @constructor.attributes, (attribute_name) ->
      Object.defineProperty self, attribute_name,
        get: ->
          self.get_attribute(attribute_name)
        set: (value) ->
          self.set_attribute(attribute_name, value)
  
  
  get_attribute: (name) ->
    @attributes[name]
  

  set_attribute: (name, value) ->
    previous_value = @get_attribute(name)
    if value != previous_value
      @updated_at       = new Date
      @__changed        = true
      @attributes[name] = value
    @get_attribute(name)
  

  set_attributes: (attributes = {}) ->
    self = @
    _.each @constructor.attributes, (attribute_name) ->
      self[attribute_name] = attributes[attribute_name] if _.has(attributes, attribute_name)
  
  
  update: (attributes = {}) ->
    @set_attributes(attributes)
    Arbiter.publish("#{@constructor.topic}/update", @)


  destroy: ->
    delete @constructor.instances[@uuid]
    Arbiter.publish("#{@constructor.topic}/destroy", @)

#
#
#

$.extend cc.blueprint.models,
  Base: Base
