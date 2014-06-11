##= require ./node

# Shortcuts
#
tag = React.DOM


# Default colors
#
default_colors = [
  "hsl(  0,  0%, 73%)"
  "hsl( 41, 88%, 68%)"
  "hsl(139, 51%, 59%)"
  "hsl(195, 92%, 67%)"
  "hsl( 20, 92%, 65%)"
  "hsl(247, 41%, 76%)"
  "hsl(347, 93%, 77%)"
]



# Calculations
#
Calculations =
  

  getDimensions: ->
    @__dimensions ||= @getDOMNode().getBoundingClientRect()
  

  getHeight: ->
    @getDimensions().heigth
  

  getWidth: ->
    @getDimensions().width


  calculateLayout: ->
    cc.blueprint.layouts.chart(@props.root, @refs)
  
  
  reposition: ->
    layout = @calculateLayout()

    offset =
      x:  @getWidth() / 2
      y:  @props.top_padding
    

    _.each @refs, (child) =>
      child_layout = layout[child.props.key]
      child.setPosition
        left:   child_layout.x + offset.x
        top:    child_layout.y + offset.y
      
      if relation = cc.blueprint.react.Blueprint.Relation.get(child.props.key)
        parent          = @refs[relation.props.parent_key]
        parent_layout   = layout[parent.props.key]
        child_index     = parent.props.model.children.indexOf(child.props.model)

        relation.setPosition
          parent_left:  parent_layout.x  + offset.x - parent.getWidth() / 2 + parent_layout.connections[child_index]
          parent_top:   parent_layout.y  + offset.y + parent.getHeight() / 2
          child_left:   child_layout.x   + offset.x
          child_top:    child_layout.y   + offset.y - child.getHeight() / 2
          midpoint:     parent_layout.midpoints[child_index] + offset.y
    
#
#
#

Chart = React.createClass

  mixins: [
    Calculations
  ]
  
  
  onClick: (event) -> alert(1)


  getDefaultProps: ->
    colors:       default_colors
    top_padding:  20
  
  
  getInitialState: ->
    refreshed_at: + new Date


  componentDidMount: ->
    @reposition()
    _.each @props.subscribe_on, (message) => Arbiter.subscribe message, @refresh
   
  

  componentDidUpdate: ->
    @__dimensions = null
    @reposition()


  # Gather descendant nodes for root element
  #
  gatherNodes: ->
    _.chain(@props.root.descendants)
      .reject((descendant) -> descendant.is_deleted())
      .pluck('uuid')
      .value()
  

  # Gather relations
  #
  gatherRelations: ->
    _.chain(@props.root.descendants)
      .reject((descendant) => descendant.is_deleted() or descendant.parent == @props.root)
      .reduce(((memo, descendant) -> memo.push({ child: descendant.uuid, parent: descendant.parent_id }) ; memo), [])
      .value()
  
  
  # Refresh message
  #
  refresh: ->
    @setState
      refreshed_at: + new Date


  render: ->
    nodes = _.map @gatherNodes(), (uuid) =>
      cc.blueprint.react.Blueprint.Node {
        key: uuid
        ref: uuid
        colors: @props.colors
        can_be_edited: @props.can_be_edited
      }
    
    relations = _.map @gatherRelations(), (data) =>
      cc.blueprint.react.Blueprint.Relation {
        key:        data.child
        parent_key: data.parent
        colors: @props.colors
      }
    
    (tag.section {
      className: 'chart'
      onClick: @onClick
    },
      (tag.svg {},
        relations
      )
      (nodes)
    )


#
#
#

_.extend @cc.blueprint.react.Blueprint,
  Chart: Chart
