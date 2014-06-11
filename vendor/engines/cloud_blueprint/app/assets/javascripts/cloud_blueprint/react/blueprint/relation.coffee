# Shortcuts
#
tag = React.DOM

# Instances pool
#
instances = {}


# Draw path
#
draw_path = (coords) ->
  start_point = "M #{coords.x1} #{coords.y1}"
  upper_line  = "L #{coords.x11 || coords.x1} #{coords.y11}"
  upper_curve = "Q #{coords.x11 || coords.x1} #{coords.y12} #{coords.x12} #{coords.y22}"
  middle_line = "L #{coords.x22} #{coords.y22}"
  lower_curve = "Q #{coords.x21 || coords.x2} #{coords.y22} #{coords.x21 || coords.x2} #{coords.y21}"
  lower_line  = "L #{coords.x2} #{coords.y2}"
  
  "#{start_point} #{upper_line} #{upper_curve} #{middle_line} #{lower_curve} #{lower_line}"


# Calculate path
#
calculatePath = (x1, y1, x2, y2, midpoint) ->
  radius    = 10
  h_radius  = if (dx = Math.abs(x2 - x1) / 2) > radius then radius else dx
  sign      = if x2 > x1 then 1 else if x2 < x1 then -1 else 0

  x12 = x1 + h_radius * sign
  x22 = x2 - h_radius * sign

  y11 = midpoint - radius ; y11 = y1 if y11 < y1
  y21 = midpoint + radius ; y21 = y2 if y21 > y2
  
  draw_path
    x1:   x1
    y1:   y1
    x11:  x1
    y11:  y11
    x12:  x12
    y12:  midpoint
    x22:  x22
    y22:  midpoint
    x21:  x2
    y21:  y21
    x2:   x2
    y2:   y2

#
#
#


Relation = React.createClass


  getDefaultProps: ->
    child_model:    cc.blueprint.models.Node.get(@props.key)
    parent_model:   cc.blueprint.models.Node.get(@props.parent_key)
  
  
  componentDidUpdate: (prevProps, prevState) ->
    @getDOMNode().setAttribute('d', calculatePath(
      @state.parent_left,
      @state.parent_top,
      @state.child_left,
      @state.child_top,
      @state.midpoint
    ))
  
  
  setPosition: (position) ->
    @setState
      parent_left:  Math.round(position.parent_left)
      parent_top:   Math.floor(position.parent_top)
      child_left:   Math.round(position.child_left)
      child_top:    Math.ceil(position.child_top)
      midpoint:     Math.round(position.midpoint)


  componentDidMount: ->
    instances[@props.key] = @
  

  componentWillUnmount: ->
    delete instances[@props.key]


  render: ->
    (tag.path {
      stroke: @props.colors[@props.child_model.color_index]
      strokeWidth: 1.25
      fill: 'transparent'
    })


# Get instance from instance pool
#
Relation.get = (key) -> instances[key]

#
#
#

_.extend @cc.blueprint.react.Blueprint,
  Relation: Relation
