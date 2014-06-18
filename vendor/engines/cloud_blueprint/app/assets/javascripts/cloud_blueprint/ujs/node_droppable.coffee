#
#
#

# Transfer
#
transfer = -> cc.ui.drag_drop.transfer


# On enter
#
on_enter = (event) ->
  return unless transfer()
  on_node_enter(event) if uuid = transfer().node
    

# On leave
#
on_leave = (event) ->
  return unless transfer()
  on_node_leave(event) if uuid = transfer().node


# On move
#
on_move = (event) ->
  return unless transfer()
  on_node_move(event) if uuid = transfer().node


# On drop
#
on_drop = (event) ->
  return unless transfer()
  on_node_drop(event) if uuid = transfer().node
  delete cc.ui.drag_drop.transfer
  

#
# Node
#

insertion_points = []


# Calculate insertion points
#
calculate_insertion_points = (element, draggable_element) ->
  bounds            = element.getBoundingClientRect()
  children          = cc.blueprint.models.Node.get(element.dataset.id).children
  dw                = bounds.width / (children.length + 1)
  insertion_points  = _.map [0 .. children.length], (i) -> i * dw + dw / 2
  index             = _.indexOf _.map(children, 'uuid'), draggable_element.dataset.id
  
  if index > -1
    insertion_points[index + 0]  += dw / 2
    insertion_points[index + 1]  -= dw / 2


# Find closest insertion point
#
find_closest_insertion_point = (element, x) ->
  bounds  = element.getBoundingClientRect()
  x      -= bounds.left
  
  x = _.reduce insertion_points, (memo, point) ->
    if Math.abs(x - point) < Math.abs(x - memo) then point else memo
  , insertion_points[0]
  
  x:      x
  index:  insertion_points.indexOf(x)


# Calculate coordinates
#
calculate_coordinates = (event, x, relation_element) ->
  container_offset  = relation_element.parentNode.getBoundingClientRect()
  node_offset       = event.target.getBoundingClientRect()
  origin_offset     = event.draggableTarget.getBoundingClientRect()

  parent_left:  Math.round(node_offset.left + x - container_offset.left)
  parent_top:   Math.floor(node_offset.bottom - container_offset.top)
  child_left:   Math.round(origin_offset.left + origin_offset.width / 2 - container_offset.left)
  child_top:    Math.ceil(origin_offset.top + origin_offset.height / 2 - container_offset.top)


# On node enter
#
on_node_enter = (event) ->
  return transfer().captured = false if event.target == event.draggableTarget

  descendants_uuids = _.map(cc.blueprint.models.Node.get(event.draggableTarget.dataset.id).descendants, 'uuid')
  return transfer().captured = false if _.contains descendants_uuids, event.target.dataset.id
  
  transfer().captured = true
  calculate_insertion_points(event.target, event.draggableTarget)


# On node leave
#
on_node_leave = (event) ->
  return unless transfer().captured
  transfer().captured = false
  insertion_points = []


# On node move
#
on_node_move = (event) ->
  return unless transfer().captured
  { x }             = find_closest_insertion_point(event.target, event.pageX)
  
  relation_element  = cc.blueprint.react.Blueprint.Relation.get(transfer().node).getDOMNode()
  coordinates       = calculate_coordinates(event, x, relation_element)
  
  relation_element.setAttribute('d', "M #{coordinates.parent_left} #{coordinates.parent_top} L #{coordinates.child_left} #{coordinates.child_top}")
  
  


# On node drop
#
on_node_drop = (event) ->
  return unless transfer().captured
  
  { x, index } = find_closest_insertion_point(event.target, event.pageX)
  
  relation              = cc.blueprint.react.Blueprint.Relation.get(transfer().node)
  relation_element      = relation.getDOMNode()
  coordinates           = calculate_coordinates(event, x, relation_element)
  coordinates.midpoint  = (coordinates.parent_top + coordinates.child_top) / 2

  relation.setPosition(coordinates)


  node = cc.blueprint.models.Node.get(transfer().node)

  node.update
    position:   index - 0.5
    parent_id:  event.target.dataset.id
  
  Arbiter.publish("#{node.constructor.broadcast_topic()}/update")
  
  _.delay ->
    cc.blueprint.models.Node.sync()
  , 250
  
  transfer().captured = false
  insertion_points = []


#
# Observer
#

observer = (container, selector) ->
  
  $container = $(container)
  
  $container.on 'cc::drag:drop:enter', selector, on_enter
  $container.on 'cc::drag:drop:leave', selector, on_leave
  $container.on 'cc::drag:drop:move',  selector, on_move
  $container.on 'cc::drag:drop:drop',  selector, on_drop


#
#
#

_.extend cc.blueprint.common,
  node_droppable: observer
