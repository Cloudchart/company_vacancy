svg_namespace = 'http://www.w3.org/2000/svg'


build = (container) ->
  path = document.createElementNS(svg_namespace, 'path')

  path.classList.add('relation')
    
  path.setAttribute('fill', 'transparent')
  path.setAttribute('stroke', 'black')
  path.setAttribute('stroke-width', '1.25')
  
  container.appendChild(path)

  path


animate = (element, path, duration) ->
  animation = document.createElementNS(svg_namespace, 'animate')

  animation.setAttribute('attributeType', 'XML')
  animation.setAttribute('attributeName', 'd')
  animation.setAttribute('from', element.getAttribute('d') || path)
  animation.setAttribute('to', path)
  animation.setAttribute('dur', "#{duration}ms")
  animation.setAttribute('fill', 'freeze')

  element.appendChild(animation)
  
  _.delay ->
    element.setAttribute('d', path)
    element.removeChild(animation)
  , duration


#
#
#


class Relation

  @instances: {}
  
  
  constructor: (@child, @parent, @container) ->
    @uuid                         = @child.uuid
    @constructor.instances[@uuid] = @
  
  
  render: ->
    @element = build(@container) unless @element
    @
  
  
  position: (position = {}) ->
    if position.x1 and position.y1 and position.x2 and position.y2
      
      radius = 10
      
      dx = @parent.width() / (@parent.instance.children().length + 1)
      
      x1 = position.x1 - @parent.width() / 2 + dx * (@child.index() + 1)
      y1 = position.y1 + @parent.height() / 2
      
      x2 = position.x2
      y2 = position.y2 - @child.height() / 2
      
      sign = if x2 < x1 then -1 else 1
      
      dy  = if position.side_index? and position.side_children?
        (position.side_index + 1) / (position.side_children + 1)
      else
        .5
      
      h_radius = if Math.abs(x2 - x1) > radius * 2 then radius else Math.abs(x2 - x1) / 2
      
      nodes_top = Math.min(y2, position.top || Infinity)
      
      middle = y1 + (nodes_top - y1) * (1 - dy)
      
      upper_line  = "V #{if middle - radius < y1 then y1 else middle - radius}"
      upper_curve = "Q #{x1} #{middle} #{x1 + h_radius * sign} #{middle}"
      middle_line = "H #{x2 - h_radius * sign}"
      lower_curve = "Q #{x2} #{middle} #{x2} #{if middle + radius > y2 then y2 else middle + radius}"
      lower_line  = "V #{y2}"
      
      animate(@element, "M #{x1} #{y1} #{upper_line} #{upper_curve} #{middle_line} #{lower_curve} #{lower_line}", 100)
    
  
  destroy: ->
    @element.parentNode.removeChild(@element) if @element and @element.parentNode
    @element = null
    delete @constructor.instances[@uuid]


#
#
#

_.extend cc.blueprint.views,
  Relation: Relation
