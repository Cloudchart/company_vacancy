# Prepare descriptor
#

prepare_descriptor = (root, node, view) ->
  id:         node.uuid
  knots:      node.knots
  parent_id:  if node == root then null else node.parent_id
  children:   []
  width:      view.width || view.getWidth()   if view
  height:     view.width || view.getHeight()  if view


# Horizontal distance
#
horizontal_distance = (left_node, right_node) ->
  padding   = if left_node.parent_id == right_node.parent_id then 20 else 50
  padding  /= 2 if !left_node.id or !right_node.id
  padding  += (left_node.width + right_node.width) / 2


# Position levels
#
position_levels = (root, descriptors) ->
  start     = if root instanceof cc.blueprint.models.Chart then 1 else 0
  
  max_level = _.reduce descriptors, (memo, descriptor) ->
    if memo > descriptor.level then memo else descriptor.level
  , 0
  
  max_height_on_previous_level  = 0
  level_offset                  = 0
  
  _.each [start..max_level], (level) ->
    descriptors_on_level = _.filter descriptors, (descriptor) -> descriptor.level == level
    
    max_height_on_level = _.reduce descriptors_on_level, (memo, descriptor) ->
      if memo > descriptor.height then memo else descriptor.height
    , 0
    
    level_offset += max_height_on_level / 2 + max_height_on_previous_level / 2
    
    _.each descriptors_on_level, (descriptor) -> descriptor.y = level_offset
    
    max_height_on_previous_level = max_height_on_level
    
    level_offset += 75


# Calculate connections
#
calculate_connections = (descriptors) ->
  _.each descriptors, (descriptor) ->
    return unless descriptor.children.length > 0 and descriptor.width
    descriptor.connections_delta  = descriptor.width / (descriptor.children.length + 1)
    descriptor.connections        = _.reduce [1 .. descriptor.children.length], ((memo, i) -> memo.push i * descriptor.connections_delta ; memo), []


# Calculate midpoints
#
calculate_midpoints = (descriptors) ->
  _.each descriptors, (descriptor) ->
    return unless descriptor.children.length > 0 and descriptor.width

    counts = _.reduce descriptor.children, (memo, child, i) ->
      connection_point = descriptor.x - descriptor.width / 2 + descriptor.connections[i]
      if child.x < connection_point
        memo.lt++
      else if child.x > connection_point
        memo.gt++
      else
        memo.eq++
      memo
    , { lt: 0, eq: 0, gt: 0 }
    
    descriptor.midpoints = []
    
    top         = descriptor.y + descriptor.height / 2
    bottom      = descriptor.children[0].y
    
    # lt
    lt_children = descriptor.children[0 ... counts.lt]
    max_height  = Math.max(_.pluck(lt_children, 'height')...)
    if max_height > -Infinity
      dh = (bottom - max_height / 2 - top) / (lt_children.length + 1)
      _.each lt_children, (child, i) ->
        descriptor.midpoints.push top + dh * (i + 1)
    
    # eq
    eq_children = descriptor.children[counts.lt ... counts.lt + counts.eq]
    max_height  = Math.max(_.pluck(eq_children, 'height')...)
    if max_height > -Infinity
      dh = (bottom - max_height / 2 - top) / (eq_children.length + 1)
      _.each eq_children, (child, i) ->
        descriptor.midpoints.push top + dh
    
    # gt
    gt_children = descriptor.children[counts.lt + counts.eq ... counts.length]
    max_height  = Math.max(_.pluck(gt_children, 'height')...)
    if max_height > -Infinity
      dh = (bottom - max_height / 2 - top) / (gt_children.length + 1)
      _.each gt_children, (child, i) ->
        descriptor.midpoints.push top + dh * (gt_children.length - i)


#
# Layout
#

layout = (root, views) ->
  nodes = root.descendants
  
  # Prepare descriptors
  #
  descriptors = _.reduce [root, nodes...], (memo, node) ->
    memo[node.uuid] = prepare_descriptor(root, node, views[node.uuid])
    memo
  , {}
  
  # Connect descriptors
  #
  _.each nodes, (node) ->
    descriptor = descriptors[node.uuid]
    descriptor.parent = descriptors[descriptor.parent_id || root.uuid]
    descriptor.parent.children.push(descriptor)
    
  # Calculate tree layout
  #
  cc.blueprint.layouts.tree descriptors[root.uuid],
    h_distance: horizontal_distance
  
  # Position levels
  #
  position_levels(root, descriptors)
  
  # Calculate connections
  #
  calculate_connections(descriptors)
  
  # Calculate midpoints
  #
  calculate_midpoints(descriptors)
  
  #
  #
  descriptors


#
#
#

_.extend @cc.blueprint.layouts,
    chart: layout
