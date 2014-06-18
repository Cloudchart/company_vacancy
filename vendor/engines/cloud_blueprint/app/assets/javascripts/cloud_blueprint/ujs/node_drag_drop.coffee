# Current drag/drop
#
draggable_origin  = {}
droppable_origin  = {}

# Transfer
#
transfer = -> cc.ui.drag_drop.transfer ||= {}

#
# Utility functions
#

# Calculate insertion points
#
calculate_insertion_points = (element) ->
  bounds                  = element.getBoundingClientRect()
  children                = cc.blueprint.models.Node.get(element.dataset.id).children
  dw                      = bounds.width / (children.length + 1)
  draggable_origin.insertion_points = _.map [0 .. children.length], (i) -> i * dw + dw / 2
  index                   = _.indexOf _.map(children, 'uuid'), draggable_origin.uuid
  
  if index > -1
    draggable_origin.insertion_points[index + 0]  += dw / 2
    draggable_origin.insertion_points[index + 1]  -= dw / 2


# Find closest insertion point
#
find_closest_insertion_point = (element, x) ->
  bounds  = element.getBoundingClientRect()
  x      -= bounds.left
  
  x = _.reduce draggable_origin.insertion_points, (memo, point) ->
    if Math.abs(x - point) < Math.abs(x - memo) then point else memo
  , draggable_origin.insertion_points[0]
  
  x:      x
  index:  draggable_origin.insertion_points.indexOf(x)
  

# Capture node
#
capture_node = (element) ->
  droppable_uuid  = element.dataset.id
  
  return false if draggable_origin.uuid == droppable_uuid
  return false if _.contains(draggable_origin.descendants, droppable_uuid)
  
  # Calculate insertion points
  #
  calculate_insertion_points(element)
  
  return true
  
  

# On node drag start
#
on_node_drag_start = (element, options = {}) ->
  # Store UUID
  draggable_origin.uuid               = element.dataset.id
  # Store relation
  draggable_origin.relation           = cc.blueprint.react.Blueprint.Relation.get(draggable_origin.uuid)
  # Store relation element
  draggable_origin.relation_element   = draggable_origin.relation.getDOMNode() if draggable_origin.relation
  # Store node
  draggable_origin.node               = cc.blueprint.react.Blueprint.Node.get(draggable_origin.uuid)
  # Store node element
  draggable_origin.node_element       = draggable_origin.node.getDOMNode()
  # Store descendants UUIDs
  draggable_origin.descendants        = _.pluck draggable_origin.node.props.model.descendants, 'uuid'
  
  return unless draggable_origin.relation
  
  # Transfer
  transfer().node = element.dataset.id
  

# On node drag move
#
on_node_drag_move = (element, options = {}) ->
  return unless draggable_origin.relation_element
  return if transfer().captured

  node_offset       = element.getBoundingClientRect()
  container_offset  = draggable_origin.relation_element.parentNode.getBoundingClientRect()
  
  x1  = node_offset.left + node_offset.width / 2 - container_offset.left
  y1  = node_offset.top + node_offset.height / 2 - container_offset.top
  x2  = options.x - container_offset.left
  y2  = options.y - container_offset.top
  
  draggable_origin.relation_element.setAttribute('d', "M #{x1} #{y1} L #{x2} #{y2}")


# On node drag end
#
on_node_drag_end = (element, options = {}) ->
  # Reset relation
  draggable_origin.relation.refresh() if draggable_origin.relation
  # Cleanup origin
  draggable_origin = {}


#
# Observer
#
observer = (container, selector) ->
  
  cc.ui.drag_drop container, selector,
    helper: false
    revert: false
    
    on_start: on_node_drag_start
    on_move:  on_node_drag_move
    on_end:   on_node_drag_end


#
#
#

_.extend cc.blueprint.common,
  node_drag_drop: observer

###
# Calculate path
#
calculate_path = (container, element, x, y) ->
  container_rect  = container.getBoundingClientRect()
  element_rect    = element.getBoundingClientRect()
  
  x2 = element_rect.left + element_rect.width / 2 - container_rect.left
  y2 = element_rect.top + element_rect.height / 2 - container_rect.top
  x1 = x - container_rect.left
  y1 = y - container_rect.top
  
  dx = (x2 - x1) / 2
  dy = (y2 - y1) / 2

  x1:   x1
  y1:   y1
  x11:  x1
  y11:  y1
  x12:  x1 + dx
  y12:  y1 + dy
  x22:  x2 - dx
  y22:  y2 - dy
  x21:  x2
  y21:  y2
  x2:   x2
  y2:   y2
###