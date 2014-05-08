template = null

build = (instance, $container) ->
  template ||= new t($('#node-template').html())
  
  $(template.render(instance)).appendTo($container)


#
#
#

class Node

  
  @instances: {}
  

  constructor: (@instance, container) ->
    @$container = $(container) ; throw 'Container for Node View not found' if @$container.length == 0

    @uuid                         = @instance.uuid
    @constructor.instances[@uuid] = @
  

  render: ->
    @__dimensions = null
    @$element   = build(@instance, @$container)
    @$element
  
  
  position: (position = {}) ->
    if position.x && position.y
      @$element.velocity
        opacity:  1
        left:     position.x - @width() / 2
        top:      position.y - @height() / 2
      , 1
    else
      x: @dimensions().left + @width() / 2
      y: @dimensions().top + @height() / 2
  
  
  width: ->
    @dimensions().width
  

  height: ->
    @dimensions().height
  
  
  dimensions: ->
    @__dimensions ||= @$element.get(0).getBoundingClientRect()
  

  destroy: ->
    @$element.remove() if @$element
    delete @constructor.instances[@uuid]
  

#
#
#

_.extend cc.blueprint.views,
  Node: Node
