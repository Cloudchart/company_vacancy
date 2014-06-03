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
    _.map @element.childNodes, (node) -> cc.blueprint.models[node.dataset.className].get(node.id)
  
  
  __descendants: ->
    _.map @element.querySelectorAll('*'), (node) -> cc.blueprint.models[node.dataset.className].get(node.id)

#
#
#

_.extend cc.blueprint.models,
  Element: Element
