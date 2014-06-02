###

# Validate parent after chart sync
#
validate_node = (node) ->
  node if node instanceof cc.blueprint.models.Node and cc.blueprint.models.Node.instances[node.uuid]

# Validate right sibling after chart sync
#
validate_right_sibling = (node, parent) ->
  node if node instanceof cc.blueprint.models.Node and cc.blueprint.models.Node.instances[node.uuid] and node.parent() == parent

#
#
#

__id = 0

activate_chart = (chart, chart_view, nodes_url) ->
  $document                 = $(document)
  chart_container_selector  = 'section[data-behaviour~="chart-container"]'
  
  # Set Node load url
  #
  cc.blueprint.models.Node.load_url = nodes_url
  
  # Parent and Child for new node insertion
  #
  parent        = null
  right_sibling = null
  
  
  # Create node
  #
  
  create_node = (attributes) ->
    
    # Check parent after chart sync
    parent = validate_node(parent) || chart
    
    # Check right sibling after chart sync
    right_sibling = validate_right_sibling(right_sibling, parent)
    
    # Set parent uuid if it exists
    attributes['parent_id'] = parent.uuid unless parent == chart
    
    # Set position of right sibling or become last child of parent
    attributes['position']  = if right_sibling then right_sibling.position else parent.children().length
    
    # shift right sibling if it exists
    right_sibling.shift_right() if right_sibling
    
    # Create node
    cc.blueprint.models.Node.create(attributes)
    
    # Reposition nodes
    parent.reposition()
    
    # Cleanup parent and right sibling
    parent = right_sibling = null
  

  
  
  # Update node
  #
  update_node = (uuid, attributes) ->
    cc.blueprint.models.Node.update(uuid, attributes)
  

  # Delete node
  #
  delete_node = (uuid) ->
    cc.blueprint.models.Node.delete(uuid)
    
  
  # Observe clicks on chart container
  #
  $document.on 'click', chart_container_selector, (event) ->
    event.stopPropagation()

    # Calculate insertion point
    { parent, right_sibling } = calculate_insert_position(chart, $('.node', chart_container_selector), { x: event.pageX, y: event.pageY })
    
    # Request new node form
    $.ajax
      url:      "#{nodes_url}/new"
      type:     'GET'
      dataType: 'script'
###

# Calculate insert position
#
calculate_insert_position = (element, x, y) ->
  chart = cc.blueprint.models.Chart.get(element.dataset.id) ; throw 'Chart not found for insert position calculation' unless chart
  
  descriptors = _.map element.querySelectorAll('[data-behaviour~="node"]'), (node) ->
    bounds = node.getBoundingClientRect()
    
    #node:   node
    uuid:   node.dataset.id
    bottom: bounds.bottom
    center: bounds.left + bounds.width / 2
    dx:     Math.min(Math.abs(x - bounds.left), Math.abs(x - bounds.right))

  parent = _.chain(descriptors)
    .reduce(
      (memo, descriptor) ->
        return memo if descriptor.bottom > y
        return [descriptor] if memo.length == 0 or memo[0].bottom < descriptor.bottom
        memo.push(descriptor) if memo[0].bottom == descriptor.bottom
        return memo
      , []
    )
    .reduce(
      (memo, descriptor) ->
        return descriptor unless memo
        return descriptor if descriptor.dx < memo.dx
        return memo
      , null
    )
    .value()

  parent        = if parent then cc.blueprint.models.Node.get(parent.uuid) else chart
  children_ids  = _.map parent.children, 'uuid'

  right_sibling = _.chain(descriptors)
    .filter(
      (descriptor) ->
        _.contains(children_ids, descriptor.uuid)
    )
    .reduce(
      (memo, descriptor) ->
        return memo if descriptor.center < x
        return descriptor unless memo
        return descriptor if descriptor.center < memo.center
        return memo
      , null
        
    )
    .value()
  
  right_sibling = if right_sibling then cc.blueprint.models.Node.instances[right_sibling.uuid] else null
  
  parent:         parent
  right_sibling:  right_sibling


# Spinner
#
spinner = '<div class="lock"><i class="fa fa-spinner fa-spin"></i></div>'


# On Chart click
#
parent          = null
right_sibling   = null

on_chart_click = (event) ->
  event.preventDefault()
  event.stopPropagation()
  
  cc.ui.modal(cc.blueprint.common.spinner, { locked: true })
  cc.blueprint.models.Node.new_form()
  
  { parent, right_sibling } = calculate_insert_position(@, event.pageX, event.pageY)


# On Node click
#

on_node_click = (event) ->
  event.preventDefault()
  event.stopPropagation()

  cc.ui.modal(cc.blueprint.common.spinner, { locked: true })
  cc.blueprint.models.Node.edit_form(@dataset.id)


# On Node form submit
#
field_attribute_re  = /node\[([^\]]*)\]/

on_node_form_submit = (event) ->
  event.preventDefault()
  
  attributes = _.reduce $(@).serializeArray(), (memo, entry) ->
    memo[match[1]] = entry.value if match = entry.name.match(field_attribute_re) ; memo
  , {}

  # Update node
  if model = cc.blueprint.models.Node.get(@dataset.id)
    model.update(attributes)
  
  # Create node
  else
    
    # Set parent attribute
    if parent instanceof cc.blueprint.models.Node
      attributes.parent_id = parent.uuid
    
    # Set position if right sibling exists
    if right_sibling instanceof cc.blueprint.models.Node
      attributes.position = right_sibling.position - .5
      right_sibling.parent.consolidate()

    # Set position if there is no right sibling
    else
      attributes.position = parent.children.length
      
    cc.blueprint.models.Node.create(attributes)
  
  cc.ui.modal.close()


# On Node form delete button click
#
on_node_form_delete_button_click = (event) ->
  event.preventDefault()
  
  cc.blueprint.models.Node.get(@dataset.id).destroy()
  
  cc.ui.modal.close()

# Variables for node drag
#

node_drag_drop_origin = {}

# Activate node drag drop
#
activate_node_drag_drop = ($container, selector) ->
  cc.ui.drag_drop $container, selector,
    helper: false
    drop_on: 'node'
  
  $container.on "cc::drag:start", selector, on_node_drag_start
  $container.on "cc::drag:move",  selector, on_node_drag_move
  $container.on "cc::drag:end",   selector, on_node_drag_end

  node_drag_drop_origin.activate_node_drag_droppables = ->
    activate_node_drag_droppables($container, selector)
  
  node_drag_drop_origin.deactivate_node_drag_droppables = ->
    deactivate_node_drag_droppables($container, selector)
  
  
# Activate node drag droppables
#
activate_node_drag_droppables = ($container, selector) ->
  $container.on "cc::drag:drop:enter",  selector, on_node_drag_droppable_enter
  $container.on "cc::drag:drop:leave",  selector, on_node_drag_droppable_leave
  $container.on "cc::drag:drop:move",   selector, on_node_drag_droppable_move
  $container.on "cc::drag:drop:drop",   selector, on_node_drag_droppable_drop
  

# Dectivate node drag droppables
#
deactivate_node_drag_droppables = ($container, selector) ->
  $container.off "cc::drag:drop:enter", selector, on_node_drag_droppable_enter
  $container.off "cc::drag:drop:leave", selector, on_node_drag_droppable_leave
  $container.off "cc::drag:drop:move",  selector, on_node_drag_droppable_move
  $container.off "cc::drag:drop:drop",  selector, on_node_drag_droppable_drop


# Calculate path for node drag
#
calculate_path_for_node_drag = (element, x, y) ->
  element_rect    = element.getBoundingClientRect()
  container_rect  = node_drag_drop_origin.relation.element.parentNode.getBoundingClientRect()
  
  x1 = x - container_rect.left
  y1 = y - container_rect.top
  x2 = element_rect.left + element_rect.width / 2 - container_rect.left
  y2 = element_rect.top + element_rect.height / 2 - container_rect.top
  
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


# Calculate insertion points for parent node
#
calculate_insertion_points = (parent, child) ->
  parent_view     = cc.blueprint.views.Node.get(parent.dataset.id)
  parent_rect     = parent.getBoundingClientRect()
  children_count  = parent_view.instance.children.length
  dw              = parent_rect.width / (children_count + 1)

  insertion_points = _.map [0 .. children_count], (i) -> i * dw + dw / 2 + parent_rect.left

  if cc.blueprint.models.Node.get(child.dataset.id).parent_id == parent.dataset.id
    index = cc.blueprint.views.Node.get(child.dataset.id).index()
    insertion_points[index]      += dw / 2
    insertion_points[index + 1]  -= dw / 2
  
  insertion_points


# Calculate insertion point for child node
calculate_insertion_point = (x) ->
  x = _.reduce node_drag_drop_origin.insertion_points, (memo, position) ->
    if Math.abs(position - x) < Math.abs(memo - x) then position else memo
  , node_drag_drop_origin.insertion_points[0]
  
  x:      x
  index:  _.indexOf node_drag_drop_origin.insertion_points, x
  

# On node drag start
#
on_node_drag_start = (event) ->
  node_drag_drop_origin.relation = cc.blueprint.views.Relation.get(@dataset.id)
  node_drag_drop_origin.activate_node_drag_droppables()
  


# On node drag move
#
on_node_drag_move = (event) ->
  return if node_drag_drop_origin.captured_by

  path = calculate_path_for_node_drag(@, event.pageX, event.pageY)
  
  node_drag_drop_origin.relation.position
    path: "M #{path.x1} #{path.y1} L #{path.x2} #{path.y2}"


# On node drag end
#
on_node_drag_end = (event) ->
  node_drag_drop_origin.relation.position({ cached: true })
  delete node_drag_drop_origin.relation
  node_drag_drop_origin.deactivate_node_drag_droppables() unless node_drag_drop_origin.captured_by
    


# On node drag droppable enter
#
on_node_drag_droppable_enter = (event) ->
  # Return if over self
  return if @ == event.draggableTarget

  # Return if over descendant
  model = cc.blueprint.models.Node.get(event.draggableTarget.dataset.id)
  uuids = _.map model.descendants, 'uuid'
  return if _.contains(uuids, @dataset.id)
  
  node_drag_drop_origin.captured_by = @
  node_drag_drop_origin.captured_by.classList.add('captured')
    
  node_drag_drop_origin.insertion_points = calculate_insertion_points(@, event.draggableTarget)


# On node drag droppable leave
#
on_node_drag_droppable_leave = (event) ->
  return unless node_drag_drop_origin.captured_by

  node_drag_drop_origin.captured_by.classList.remove('captured')
  delete node_drag_drop_origin.captured_by
  delete node_drag_drop_origin.insertion_points
  delete node_drag_drop_origin.drop_index


# On node drag droppable move
#
on_node_drag_droppable_move = (event) ->
  return unless node_drag_drop_origin.captured_by
  
  { x, index } = calculate_insertion_point(event.pageX)
  
  node_drag_drop_origin.drop_index = index

  path = calculate_path_for_node_drag(event.draggableTarget, x, @getBoundingClientRect().bottom)
  node_drag_drop_origin.relation.position
    path: "M #{path.x1} #{path.y1} L #{path.x2} #{path.y2}"
  

# On node drag droppable drop
#
on_node_drag_droppable_drop = (event) ->
  node_drag_drop_origin.captured_by.classList.remove('captured') if node_drag_drop_origin.captured_by
  
  # Drop
  if node_drag_drop_origin.captured_by
    $(event.draggableTarget).trigger("node::drop", { parent: node_drag_drop_origin.captured_by, index: node_drag_drop_origin.drop_index })

  delete node_drag_drop_origin.captured_by
  delete node_drag_drop_origin.insertion_points
  delete node_drag_drop_origin.drop_index

  node_drag_drop_origin.deactivate_node_drag_droppables()
  

#
#
#

_.extend cc.blueprint.common,
  spinner:                            spinner
  on_chart_click:                     on_chart_click
  on_node_click:                      on_node_click
  on_node_form_submit:                on_node_form_submit
  on_node_form_delete_button_click:   on_node_form_delete_button_click
  activate_node_drag_drop:            activate_node_drag_drop
