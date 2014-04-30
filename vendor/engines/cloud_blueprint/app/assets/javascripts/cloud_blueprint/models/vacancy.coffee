@cc                   ?= {}
@cc.blueprint         ?= {}
@cc.blueprint.models  ?= {}

#
#
#

instances = {}

#
#
#

class Vacancy
  
  @attributes: ['uuid', 'name', 'description']

  @instances: instances
  
  @topic:     'cc::blueprint::models::vacancy'
  
  @load_url:  null
  
  @template:  null
  
  
  @load: ->
    $.ajax
      url:      @load_url
      type:     'GET'
      dataType: 'json'
    
    .done (records) ->
      _.each records, (attributes) -> new Vacancy(attributes)
      Arbiter.publish("#{Vacancy.topic}/load", instances)

    .fail ->
      # pass
      


  constructor: (attributes = {}) ->
    @uuid             = attributes['uuid']
    @name             = attributes['name']
    @description      = attributes['description']
    
    instances[@uuid]  = @

    Arbiter.publish("#{Vacancy.topic}/new", @)
  
  
  update: (attributes = {}) ->
    _.each @constructor.attributes, (attribute_name) =>
      @[attribute_name] = attributes[attribute_name] if attributes[attribute_name]?

    Arbiter.publish("#{Vacancy.topic}/update", @)
  

  destroy: ->
    delete @constructor.instances[@uuid]

    Arbiter.publish("#{Vacancy.topic}/destroy", @)


  render: ->
    @constructor.template.render
      uuid:         @uuid
      name:         @name
      description:  @description


#
#
#

$.extend cc.blueprint.models,
  Vacancy: Vacancy
