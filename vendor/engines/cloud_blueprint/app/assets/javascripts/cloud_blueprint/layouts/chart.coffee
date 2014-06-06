# Prepare descriptor
#

prepare_descriptor = (node, view) ->
  id:         node.uuid
  knots:      node.knots
  parent_id:  if node instanceof cc.blueprint.models.Chart then null else node.parent_id
  children:   []
  width:      view.getWidth()   if view
  height:     view.getHeight()  if view


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
    
    level_offset += max_height_on_level / 2
    
    _.each descriptors_on_level, (descriptor) -> descriptor.y = level_offset
    
    max_height_on_previous_level = max_height_on_level
    
    level_offset += 100



#
# Layout
#

layout = (root, views) ->
  nodes = root.descendants
  
  # Prepare descriptors
  #
  descriptors = _.reduce [root, nodes...], (memo, node) ->
    memo[node.uuid] = prepare_descriptor(node, views[node.uuid])
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
  
  #
  #
  descriptors


#
#
#

_.extend @cc.blueprint.layouts,
    chart: layout
