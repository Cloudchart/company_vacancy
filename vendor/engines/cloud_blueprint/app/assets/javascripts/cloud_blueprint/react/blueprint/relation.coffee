###
  Used in:

  cloud_blueprint/controllers/chart
  cloud_blueprint/react/blueprint/chart
  cloud_blueprint/react/blueprint/node
  cloud_blueprint/ujs/node_draggable
###

# Shortcuts
#
tag = React.DOM

# Instances pool
#
instances = {}


# Draw path
#

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


# Render path
#
drawPath = (relation, coords) ->
  start_point = "M #{coords.x1} #{coords.y1}"
  upper_line  = "L #{coords.x11 || coords.x1} #{coords.y11}"
  upper_curve = "Q #{coords.x11 || coords.x1} #{coords.y12} #{coords.x12} #{coords.y22}"
  middle_line = "L #{coords.x22} #{coords.y22}"
  lower_curve = "Q #{coords.x21 || coords.x2} #{coords.y22} #{coords.x21 || coords.x2} #{coords.y21}"
  lower_line  = "L #{coords.x2} #{coords.y2}"
  
  relation.getDOMNode().setAttribute('d', "#{start_point} #{upper_line} #{upper_curve} #{middle_line} #{lower_curve} #{lower_line}")


# Morph relation
#
morph = (relation, prevState) ->
  path = calculatePath(relation.state.parent_left, relation.state.parent_top, relation.state.child_left, relation.state.child_top, relation.state.midpoint)

  return drawPath(relation, path) unless prevState.midpoint?
  
  prevPath = calculatePath(prevState.parent_left, prevState.parent_top, prevState.child_left, prevState.child_top, prevState.midpoint)
  
  duration  = 200
  start     = null
  
  deltas = _.reduce ['parent_left', 'parent_top', 'child_left', 'child_top', 'midpoint'], (memo, key) ->
    memo[key] = relation.state[key] - prevState[key] ; memo
  , {}
  
  tick = (timestamp) ->
    start     = timestamp unless start
    progress  = timestamp - start
    delta     = progress / duration
    delta     = 1 if delta > 1
    
    values = _.reduce deltas, (memo, value, key) ->
      memo[key] = prevState[key] + deltas[key] * delta ; memo
    , {}
    
    drawPath(relation, calculatePath(values.parent_left, values.parent_top, values.child_left, values.child_top, values.midpoint))
    
    if progress <= duration then requestAnimationFrame(tick) else drawPath(relation, path)
    
  
  
  requestAnimationFrame(tick)


#
#
#


Relation = React.createClass


  getInitialState: ->
    child_model:    cc.blueprint.models.Node.get(@props.key)
    parent_model:   cc.blueprint.models.Node.get(@props.parent_key)
  
  
  componentDidUpdate: (prevProps, prevState) ->
    morph @, prevState
  
  
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
  
  
  refresh: ->
    @setState
      refreshed_at: + new Date


  render: ->
    (tag.path {
      stroke: @props.colors[@state.child_model.color_index]
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
