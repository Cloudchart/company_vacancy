# Shortcuts
#
tag = React.DOM

# Instances pool
#
instances = {}


# Calculate path
#
calculatePath = (x1, y1, x2, y2, midpoint) ->
  "M #{x1} #{y1} C #{x1} #{midpoint} #{x2} #{midpoint} #{x2} #{y2}"

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
