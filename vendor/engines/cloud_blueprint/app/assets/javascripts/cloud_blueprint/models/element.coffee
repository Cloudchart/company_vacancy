namespace = 'http://cloudorgchart.com'

#
#
#

class Element extends cc.blueprint.models.Base
  
  @className: 'Element'
  
  @element_type:  null
  @child_class:   null
  
  constructor: (attributes = {}) ->
    super(attributes)
    @element                    = document.createElementNS(namespace, @constructor.element_type)
    @element.dataset.className  = @constructor.className
    @element.id                 = @uuid
    
    @define_properties()
  
  
  destroy: ->
    super()
    @element.parentNode.removeChild(@element) if @element.parentNode
    @
  
  
  define_properties: ->
    self = @
    _.each ['parent', 'children', 'descendants'], (name) -> Object.defineProperty self, name, { get: self["__#{name}"] }


  __parent: ->
    cc.blueprint.models[@element.parentNode.dataset.className].get(@element.parentNode.id) if @element.parentNode
    
  
  __children: ->
    _.chain(@element.childNodes)
      .map((node) -> cc.blueprint.models[node.dataset.className].get(node.id))
      .reject((node) -> node.is_deleted())
      .value()
  
  
  __descendants: ->
    _.chain(@element.querySelectorAll('*'))
      .map((node) -> cc.blueprint.models[node.dataset.className].get(node.id))
      .reject((node) -> node.is_deleted())
      .value()

#
#
#

_.extend cc.blueprint.models,
  Element: Element
