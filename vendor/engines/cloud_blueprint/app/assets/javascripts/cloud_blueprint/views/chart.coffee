

horizontal_distance = (left_node, right_node) ->
  padding   = if left_node.parent_id == right_node.parent_id then 20 else 50
  padding  /= 2 if !left_node.id or !right_node.id
  padding  += (left_node.width + right_node.width) / 2


prepare_descriptor = (node) ->
  view = cc.blueprint.views.Node.instances[node.uuid]
  
  id:         node.uuid
  parent_id:  if node instanceof cc.blueprint.models.Chart then null else node.parent_id
  width:      if view? then view.width()   else 0
  height:     if view? then view.height()  else 0
  children:   []


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
  
  # Calculate tree layout
  cc.blueprint.layouts.tree descriptors[root.uuid],
    h_distance: horizontal_distance
  
  position_levels(root, descriptors)
  
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
    _.chain(models).select((model) -> !views[model.uuid]).each((model) -> new cc.blueprint.views.Node(model, $container))

    # Delete views for deleted models
    views_to_delete = _.select views, (view) -> !models[view.uuid]


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
    
    _.each cc.blueprint.views.Node.instances, (node) ->
      node.position
        x: layout.positions[node.uuid].x + x_offset
        y: layout.positions[node.uuid].y + y_offset
    
  

#
#
#

_.extend cc.blueprint.views,
  Chart: Chart
