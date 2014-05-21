

horizontal_distance = (left_node, right_node) ->
  padding   = if left_node.parent_id == right_node.parent_id then 20 else 50
  padding  /= 2 if !left_node.id or !right_node.id
  padding  += (left_node.width + right_node.width) / 2


prepare_descriptor = (node) ->
  view = cc.blueprint.views.Node.instances[node.uuid]
  
  id:         node.uuid
  knots:      node.knots
  parent_id:  if node instanceof cc.blueprint.models.Chart then null else node.parent_id
  width:      if view? then view.width()   else 0
  height:     if view? then view.height()  else 0
  children:   []


append_knots = (descriptors) ->
  _.each descriptors, (descriptor) ->
    if descriptor.knots > 0 and descriptors[descriptor.parent_id]
      _.each [0 ... descriptor.knots], ->
        knot =
          parent_id:  descriptor.parent_id
          parent:     descriptor.parent
          width:      0
          height:     0
        
        descriptor.parent.children.splice(descriptor.parent.children.indexOf(descriptor), 1, knot)
        knot.children     = [descriptor]
        descriptor.parent = knot
  

remove_knots = (descriptors) ->
  _.each descriptors, (descriptor) ->
    if descriptor.knots > 0 and descriptors[descriptor.parent_id]
      _.each [0 ... descriptor.knots], ->
        knot = descriptor.parent
        descriptor.parent = knot.parent
        descriptor.parent.children.splice(descriptor.parent.children.indexOf(knot), 1, descriptor)
  

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


calculate_side_indices = (root, descriptors) ->
  children = _.pluck root.children()

  if root instanceof cc.blueprint.models.Node
    uuids               = _.pluck children, 'uuid'
    parent_descriptor   = descriptors[root.uuid]
    child_descriptors   = _.filter descriptors, (value, uuid) -> _.contains uuids, uuid
    
    left_children       = _.sortBy _.filter(child_descriptors, (descriptor) -> descriptor.x < parent_descriptor.x), 'x'
    right_children      = _.sortBy _.filter(child_descriptors, (descriptor) -> descriptor.x > parent_descriptor.x), 'x'
    
    left_top  = Math.min _.map(left_children, (child) -> child.y - child.height / 2)...
    
    right_top = Math.min _.map(right_children, (child) -> child.y - child.height / 2)...

    _.each  left_children, (descriptor, index, collection) -> descriptor.side_index = collection.length - 1 - index ; descriptor.side_children = collection.length ; descriptor.top = left_top
    _.each  right_children, (descriptor, index, collection) -> descriptor.side_index = index ; descriptor.side_children = collection.length ; descriptor.top = right_top
  
  _.each children, (child) -> calculate_side_indices(child, descriptors)


prepare_tree = (root) ->

  # Get all nodes for layout calculation
  nodes = root.descendants()
  
  # Prepare node descriptors
  descriptors = _.reduce [root, nodes...], (memo, node) ->
    memo[node.uuid] = prepare_descriptor(node) ; memo
  , {}
  
  # Make descriptors tree
  _.each nodes, (node) ->
    descriptor        = descriptors[node.uuid]
    descriptor.parent = descriptors[descriptor.parent_id || root.uuid]
    descriptor.parent.children.push(descriptor)
  
  # append knots
  append_knots(descriptors)
  
  # Calculate tree layout
  cc.blueprint.layouts.tree descriptors[root.uuid],
    h_distance: horizontal_distance
  
  # remove knots
  remove_knots(descriptors)
  
  position_levels(root, descriptors)

  calculate_side_indices(root, descriptors)
  
  layout =
    positions: descriptors
  

  layout

#
#
#

class Chart
  

  constructor: (@instance, container) ->
    @$container = $(container) ; throw 'Container for Chart View not found' if @$container.length == 0
    @root = @instance
  
  
  prepare_node_views: ->
    $container  = @$container
    models      = cc.blueprint.models.Node.instances
    views       = cc.blueprint.views.Node.instances
    
    # Create views for created models
    _.chain(models)
      .select(
        (model) -> !views[model.uuid]
      )
      .each(
        (model) -> new cc.blueprint.views.Node(model, $container, $('svg', $container).get(0))
      )

    # Delete views for deleted models
    _.chain(views)
      .reject(
        (view) -> models[view.uuid]
      )
      .invoke('destroy')


  render: ->
    # Prepare node views
    @prepare_node_views()
    
    # Render node views
    _.invoke cc.blueprint.views.Node.instances, 'render'
    
    # Calculate layout
    layout = prepare_tree(@root)
    
    # Position views
    x_offset  = @$container.innerWidth() / 2
    y_offset  = 20
    
    _.each cc.blueprint.views.Node.instances, (view) ->
      view_position = layout.positions[view.uuid]

      view.position
        x: view_position.x + x_offset
        y: view_position.y + y_offset
      
      if parent_position = layout.positions[view.instance.parent_id]
        view.relation().position
          x1: parent_position.x + x_offset
          y1: parent_position.y + y_offset
          x2: view_position.x + x_offset
          y2: view_position.y + y_offset
          side_index:     view_position.side_index
          side_children:  view_position.side_children
          top:            view_position.top
      
      

  

#
#
#

_.extend cc.blueprint.views,
  Chart: Chart
