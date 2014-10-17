###
  Used in:

  cloud_blueprint/controllers/chart
###

##= require ./node

# Shortcuts
#
tag = React.DOM

NodeIdentityStore = require('cloud_blueprint/stores/node_identity_store')


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


# Calculate insertion point
#
calculate_parent = (refs, x, y) ->
  bounds = _.reduce refs, (memo, node) ->
    rect            = node.getDOMNode().getBoundingClientRect()
    rect.uuid       = node.props.key
    rect.parent     = node.state.model.parent_id
    rect.midpoint   = rect.top + rect.height / 2
    rect.dx         = Math.min(Math.abs(rect.left - x), Math.abs(rect.right - x))
    rect.dy         = Math.abs(rect.midpoint - y)
    memo[rect.uuid] = rect
    memo
  , {}

  bounds_by_midpoint = _.reduce bounds, (memo, rect) ->
    (memo[rect.midpoint] ||= []).push(rect) ; memo
  , {}

  _.each bounds_by_midpoint, (bounds, midpoint) -> bounds_by_midpoint[midpoint] = _.sortBy bounds, 'left'

  # Find closest top level
  top_level = _.reduce bounds_by_midpoint, (memo, bounds, midpoint) ->
    if (memo == null or memo < midpoint) and midpoint < y then midpoint else memo
  , null

  # Find closets hit level
  hit_level = _.reduce bounds_by_midpoint, (memo, bounds, midpoint) ->
    return memo if midpoint > y
    if bounds[0].left < x and bounds[bounds.length - 1].right > x and midpoint > memo then midpoint else memo
  , null

  closest = (rects, key = 'dx') ->
    _.reduce rects, ((memo, rect) -> if memo[key] < rect[key] then memo else rect), rects[0] if rects

  possible_closest_parent     = closest(_.chain(bounds_by_midpoint).filter((rect, midpoint) -> midpoint < y).flatten().value())
  possible_hit_level_parent   = closest(bounds_by_midpoint[hit_level])
  possible_top_level_parent   = closest(bounds_by_midpoint[top_level])

  possible_parent             = null

  if possible_closest_parent
    if possible_hit_level_parent
      if possible_top_level_parent.parent == possible_hit_level_parent.uuid
        possible_parent = possible_top_level_parent
      else
        possible_parent = closest([possible_hit_level_parent, possible_top_level_parent])
    else
      possible_parent = closest([possible_closest_parent, possible_top_level_parent])

  if possible_parent then possible_parent.uuid else null


calculate_position = (refs, parent, x) ->
  children  = _.filter(refs, (node) -> node.state.model.parent_id == parent)

  bounds    = _.chain(refs)
    .filter (node) -> node.state.model.parent_id == parent
    .map (node) ->
      rect      = node.getDOMNode().getBoundingClientRect()
      rect.dx   = Math.min(Math.abs(rect.left - x), Math.abs(rect.right - x))
      rect
    .sortBy('left')
    .value()
  
  closest_child = _.sortBy(bounds, 'dx')[0]
  
  if closest_child
    _.indexOf(bounds, closest_child) + if (closest_child.left + closest_child.right) / 2 < x then .5 else -.5
  else
    0
  
  



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
    @layout = @calculateLayout()
    
    t = _.reduce @layout, (memo, node) ->
      return memo unless node.height
      Math.min(memo, node.y - node.height / 2)
    , 0
    
    r = _.reduce @layout, (memo, node) ->
      return memo unless node.width
      Math.max(memo, node.x + node.width / 2)
    , 0
    
    b = _.reduce @layout, (memo, node) ->
      return memo unless node.height
      Math.max(memo, node.y + node.height / 2)
    , 0
    
    l = _.reduce @layout, (memo, node) ->
      return memo unless node.width
      Math.min(memo, node.x - node.width / 2)
    , 0

    w = r - l
    h = b - t

    
    parentNodeBounds  = @getDOMNode().parentNode.getBoundingClientRect()
    parentNodeStyle   = window.getComputedStyle(@getDOMNode().parentNode)
    
    hBorders = parseFloat(parentNodeStyle.borderLeftWidth) + parseFloat(parentNodeStyle.borderRightWidth)
    vBorders = parseFloat(parentNodeStyle.borderTopWidth) + parseFloat(parentNodeStyle.borderBottomWidth)
    
    width   = Math.max(parentNodeBounds.width - hBorders, w + 80) + 600
    height  = Math.max(parentNodeBounds.height - vBorders, h + 80)
    
    
    @getDOMNode().style.width   = width + 'px'
    @getDOMNode().style.height  = height + 'px'
    
    @getDOMNode().style.left    = parentNodeBounds.width / 2 - width / 2 + 'px'
    

    offset =
      x:  width / 2
      y:  @props.top_padding
    
    
    
    

    _.each @refs, (child) =>
      child_layout = @layout[child.props.key]
      child.setPosition
        left:   child_layout.x + offset.x
        top:    child_layout.y + offset.y
      
      if relation = cc.blueprint.react.Blueprint.Relation.get(child.props.key)
        parent          = @refs[relation.props.parent_key]
        parent_layout   = @layout[parent.props.key]
        child_index     = child.state.model.index
        
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
    cc.react.mixins.Draggable
  ]
  
  
  onCCDragStart: (event) ->
    event.dataTransfer.setDragImage(false)

    @__origin =
      x: event.pageX
      y: event.pageY
  

  onCCDragMove: (event) ->
    node          = @getDOMNode()
    nodeBounds    = node.getBoundingClientRect()
    nodeStyle     = window.getComputedStyle(node)
    parentBounds  = node.parentNode.getBoundingClientRect()
    parentStyle   = window.getComputedStyle(node.parentNode)
    
    dx = @__origin.x - event.pageX
    dy = @__origin.y - event.pageY
    
    realX = parseFloat(nodeStyle.left)  - dx
    realY = parseFloat(nodeStyle.top)   - dy
    
    minX = 0
    minY = 0
    maxX = parentBounds.width   - nodeBounds.width  - parseFloat(parentStyle.borderLeftWidth) - parseFloat(parentStyle.borderRightWidth)
    maxY = parentBounds.height  - nodeBounds.height - parseFloat(parentStyle.borderTopWidth)  - parseFloat(parentStyle.borderBottomWidth)

    x = Math.min(Math.max(maxX, realX), minX)
    y = Math.min(Math.max(maxY, realY), minY)
    
    node.style.left = x + 'px'
    node.style.top  = y + 'px'
    
    @__origin.x = event.pageX
    @__origin.y = event.pageY
    
  
  
  onDropIdentity: (event) ->
    parent    = calculate_parent(@refs, event.detail.pageX, event.detail.pageY)
    position  = calculate_position(@refs, parent, event.detail.pageX)
    nodeModel = cc.blueprint.models.Node.create({ chart_id: @props.root.uuid, parent_id: parent, position: position, color_index: 0 })

    cc.blueprint.models.Node.sync()

    json = JSON.parse(event.detail.identity)

    identityModel = cc.blueprint.models.Identity.create({
      chart_id:       @props.root.uuid
      node_id:        nodeModel.uuid
      identity_id:    json.uuid
      identity_type:  json.className
    })
    
    identityModel.save()
  
  
  onClick: (event) ->
    parent    = calculate_parent(@refs, event.pageX, event.pageY)
    position  = calculate_position(@refs, parent, event.pageX)
    model     = new cc.blueprint.models.Node({ chart_id: @props.root.uuid, parent_id: parent, position: position, color_index: 0 })
    node_form = cc.blueprint.react.forms.Node({ model: model, colors: @props.colors })
    
    cc.blueprint.react.modal.show(node_form, { key: 'node', title: 'New node' })


  getDefaultProps: ->
    colors:       default_colors
    top_padding:  20
    left_padding: 300
    right_padding: 300
  
  
  getInitialState: ->
    refreshed_at: + new Date


  componentDidMount: ->
    @reposition()
    _.each @props.subscribe_on, (message) => Arbiter.subscribe message, @refresh
    @getDOMNode().addEventListener('drop:identity', @onDropIdentity)
    NodeIdentityStore.on('change', @refresh)

    if @props.root.descendants.length == 0
      Arbiter.publish "cc:blueprint:identity-filter/show"
   
  

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
    @props.root.consolidate()
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
        colors:     @props.colors
      }
    
    (tag.section {
      className:          'chart'
      onClick:            @onClick if @props.can_be_edited
      'data-behaviour':   'droppable' if @props.can_be_edited
      'data-draggable':   'on'
    },
      (tag.svg {},
        relations
      )
      (nodes)
      (tag.h1 { className: 'placeholder' }, 'Tap anywhere to add node.') if nodes.length == 0
    )


#
#
#

_.extend @cc.blueprint.react.Blueprint,
  Chart: Chart
