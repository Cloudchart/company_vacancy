# Default rendering options
#
default_options =
  min_children_links_distance: 25


# Default color indices
#
default_color_indices = [
  "hsl(  0,  0%, 73%)"
  "hsl( 41, 88%, 68%)"
  "hsl(139, 51%, 59%)"
  "hsl(195, 92%, 67%)"
  "hsl( 20, 92%, 65%)"
  "hsl(247, 41%, 76%)"
  "hsl(347, 93%, 77%)"
]


# Node template
#
template = null


# Build node view
#
build = (instance, $container, cached_position, options = {}) ->
  template ||= new t($('#node-template').html())
  
  node = $(template.render(instance)).appendTo($container)
  
  node.css('min-width', instance.element.childNodes.length * options.min_children_links_distance)
  
  node.css
    backgroundColor: cc.blueprint.views.Node.color_indices[instance.color_index]
  
  if cached_position
    node.css
      left: cached_position.x
      top:  cached_position.y
  
  node


#
#
#

class Node

  @color_indices: default_color_indices

  @className: 'Node'
  
  @instances: {}
  
  @get: (uuid) -> @instances[uuid]
  

  constructor: (@instance, container, @svg_container, options = {}) ->
    @$container = $(container) ; throw 'Container for Node View not found' if @$container.length == 0

    @options = _.defaults {}, options, default_options
    
    @uuid                         = @instance.uuid
    @constructor.instances[@uuid] = @
  

  render: ->
    #return if @$element
    @reset()
    @$element     = build(@instance, @$container, @position(), @options)
    @rendered_at  = new Date
    @$element
    @relation().render()
  
  
  reset: ->
    @$element.remove() if @$element
    @__dimensions = null
  
  
  index: ->
    _.indexOf @instance.element.parentNode.childNodes, @instance.element
  
  
  parent: ->
    @constructor.instances[@instance.parent_id]
  

  relation: ->
    @__relation ||= new cc.blueprint.views.Relation(@, @parent(), @svg_container).render()
  
  
  position: (position = {}) ->
    if position.x && position.y
      
      position =
        x: position.x - @width() / 2
        y: position.y - @height() / 2
      
      @$element.animate
        left:     position.x
        top:      position.y
      ,
        duration: if @cached_position then 200 else 0

      @cached_position = position
      
    else
      @cached_position
  
  
  width: ->
    @dimensions().width
  

  height: ->
    @dimensions().height
  
  
  dimensions: ->
    @__dimensions ||= @$element.get(0).getBoundingClientRect()
  

  destroy: ->
    @relation().destroy()
    @$element.remove() if @$element
    delete @constructor.instances[@uuid]
  

#
#
#


_.extend cc.blueprint.views,
  Node: Node
