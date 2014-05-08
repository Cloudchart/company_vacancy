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
      _.each data, (attributes) -> new self(attributes)
      Arbiter.publish("#{self.topic}/load", self.instances)
    
    .fail ->
      # pass
    

  constructor: (attributes = {}) ->
    @set_accessors()
    @set_attributes(attributes)
    @constructor.instances[@uuid] = @
    Arbiter.publish("#{@constructor.topic}/new", @)
  
  
  set_accessors: () ->
    @attributes = {}

    _.each @constructor.attributes, (attribute_name) =>
      Object.defineProperty @, attribute_name,
        get: ->
          @attributes[attribute_name]
        set: (value) ->
          @attributes[attribute_name] = value
  

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
