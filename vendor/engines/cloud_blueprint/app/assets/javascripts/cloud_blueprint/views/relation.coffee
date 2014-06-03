svg_namespace = 'http://www.w3.org/2000/svg'


build = (container) ->
  path = document.createElementNS(svg_namespace, 'path')

  path.classList.add('relation')
    
  path.setAttribute('fill', 'transparent')
  path.setAttribute('stroke-width', '1.25')
  
  container.appendChild(path)

  path


calculate_path = (parent, child, positions, options) ->
  dx = parent.width() / (parent.instance.children().length + 1)


animate_path = (element, path, cached_path = {}, duration = 250) ->
  
  deltas = _.reduce path, (memo, value, name) ->
    memo[name] = (cached_path[name] || 0) - value
    memo
  , {}
  
  start     = 0
  
  frame  = (timestamp) ->

    start     = timestamp if start == 0
    progress  = timestamp - start
    delta     = if duration == 0 then 1 else progress / duration
    delta     = 1 if delta > 1
    
    values    = _.reduce path, (memo, value, name) ->
      memo[name] = value + deltas[name] * (1 - delta)
      memo
    , {}
    
    start_point = "M #{values.x1} #{values.y1}"
    upper_line  = "L #{values.x11} #{values.y11}"
    upper_curve = "Q #{values.x11} #{values.y12} #{values.x12} #{values.y22}"
    middle_line = "L #{values.x22} #{values.y22}"
    lower_curve = "Q #{values.x21} #{values.y22} #{values.x21} #{values.y21}"
    lower_line  = "L #{values.x2} #{values.y2}"
    
    element.setAttribute('d', "#{start_point} #{upper_line} #{upper_curve} #{middle_line} #{lower_curve} #{lower_line}")

    window.requestAnimationFrame frame if progress <= duration

  window.requestAnimationFrame frame


#
#
#


class Relation

  @instances: {}
  
  @get: (uuid) -> @instances[uuid]
  
  
  constructor: (@child, @__parent, @container) ->
    @uuid                         = @child.uuid
    @constructor.instances[@uuid] = @
  
  
  parent: ->
    cc.blueprint.views.Node.instances[@child.instance.parent_id]
  

  render: ->
    @element = build(@container) unless @element
    @element.setAttribute('stroke', cc.blueprint.views.Node.color_indices[@child.instance.color_index])
    @
  
  
  position: (position = {}) ->
    if position.x1 and position.y1 and position.x2 and position.y2
      
      radius = 10
      
      dx = @parent().width() / (@parent().instance.children.length + 1)
      
      x1 = position.x1 - @parent().width() / 2 + dx * (@child.index() + 1)
      y1 = position.y1 + @parent().height() / 2
      
      x2 = position.x2
      y2 = position.y2 - @child.height() / 2
      
      sign = if x2 < x1 then -1 else 1
      
      dy  = if position.side_index? and position.side_children?
        (position.side_index + 1) / (position.side_children + 1)
      else
        .5
      
      h_radius = if Math.abs(x2 - x1) > radius * 2 then radius else Math.abs(x2 - x1) / 2
      
      middle = y1 + (Math.min(position.top || y2, y2) - y1) * (1 - dy)

      ###
      
        *(x1, y1)
        |
        *(x11, y11)
        |
        *---*(x12, y12)------*(x22, y22)---*
                                           |
                                           *(x21, y21)
                                           |
                                           *(x2, y2)

      ###
      
      x12 = x1 + h_radius * sign
      y11 = middle - radius ; y11 = y1 if y11 < y1
      x22 = x2 - h_radius * sign
      y21 = middle + radius ; y21 = y2 if y21 > y2
      
      path =
        x1:   x1
        y1:   y1
        x11:  x1
        y11:  y11
        x12:  x12
        y12:  middle
        x22:  x22
        y22:  middle
        x21:  x2
        y21:  y21
        x2:   x2
        y2:   y2

      animate_path(@element, path, @cached_path, if @cached_path then 200 else 0)

      @cached_path = path
    
    else if position.cached == true and @cached_path
      animate_path(@element, @cached_path, {}, 0)
      
    else if position.path
      @element.setAttribute('d', position.path)
    
  
  destroy: ->
    @element.parentNode.removeChild(@element) if @element and @element.parentNode
    @element = null
    delete @constructor.instances[@uuid]


#
#
#

_.extend cc.blueprint.views,
  Relation: Relation
