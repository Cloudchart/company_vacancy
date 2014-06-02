container_selector  = "section.chart"
node_selector       = "div.node"

# Get model by uuid
#
get_model = (uuid) ->
  cc.blueprint.models.Node.instances[uuid]


# Get view by uuid
#
get_view = (uuid) ->
  cc.blueprint.views.Node.instances[uuid]


# Get relation
#
get_relation = (uuid) ->
  cc.blueprint.views.Relation.instances[uuid]


# Create relation element
#
create_relation_element = (container) ->
  element = document.createElementNS('http://www.w3.org/2000/svg', 'path')
  
  element.setAttribute('fill', 'transparent')
  element.setAttribute('stroke', 'black')
  element.setAttribute('stroke-width', 1.25)
  element.setAttribute('marker-end', 'url(#insertion-circle)')
  
  container.appendChild(element)
  element


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


#
#
partition_nodes_by_availability = (target_uuid) ->
  all_uuids           = _.map document.querySelectorAll("#{container_selector} #{node_selector}"), (node) -> node.dataset.id
  not_available_uuids = _.map(get_model(target_uuid).descendants(), 'uuid')
  available_uuids     = _.difference all_uuids, not_available_uuids
  
  available_uuids:      available_uuids
  not_available_uuids:  not_available_uuids


#
#
__insert_positions = {}

calculate_insert_positions = (uuid, target_uuid) ->
  view            = get_view(uuid)
  children_count  = view.instance.children().length
  dx              = view.width() / (children_count + 1)

  __insert_positions[uuid] = _.map [0 .. children_count], (i) -> i * dx + dx / 2
  
  if get_model(target_uuid).parent_id == uuid
    index = get_view(target_uuid).index()
    __insert_positions[uuid][index]     += dx / 2
    __insert_positions[uuid][index + 1] -= dx / 2


calculate_insert_position = (uuid, x) ->
  insert_positions  = __insert_positions[uuid]
  view_rect         = get_view(uuid).$element.get(0).getBoundingClientRect()
  x                 = x - view_rect.left
  
  x = _.reduce insert_positions, (memo, position) ->
    if Math.abs(position - x) < Math.abs(memo - x) then position else memo
  , insert_positions[0]
  
  x:      view_rect.left + x
  index:  insert_positions.indexOf(x)
  

cleanup_insert_positions = ->
  __insert_positions = {}

#
#
#

activate = (chart) ->
  
  # Drag origin
  #
  origin =
    relation_container: document.querySelector("#{container_selector} svg")
  

  # Activate node drag
  #
  cc.ui.drag_drop(container_selector, node_selector, {
    helper: false
    drop_on: 'node'
  })


  # Activate droppable module
  #
  cc.ui.droppable()


  # On node drag start
  #
  $(container_selector).on "cc::drag:start", node_selector, (event) ->
    { available_uuids, not_available_uuids } = partition_nodes_by_availability(@dataset.id)
    
    _.each not_available_uuids, (uuid) ->
      view      = get_view(uuid)
      element   = view.$element.get(0)

      element.classList.add('locked')
    
    _.each available_uuids, (uuid) =>
      calculate_insert_positions(uuid, @dataset.id)
    
    origin.relation_path = get_relation(@dataset.id).element.getAttribute('d')
    
    activate_drop()
    
  
  
  # On node drag move
  #
  $(container_selector).on "cc::drag:move", node_selector, (event) ->
    return if origin.droppable
    
    x = if origin.droppable then 0 else event.pageX
    y = if origin.droppable then 0 else event.pageY

    origin.path = calculate_path(origin.relation_container, @, x, y)
    relation = get_relation(@dataset.id)
    relation.position
      path: "M #{origin.path.x1} #{origin.path.y1} L #{origin.path.x2} #{origin.path.y2}"
    
  
  
  # On node drag end
  #
  $(container_selector).on "cc::drag:end", node_selector, (event) ->
    { available_uuids, not_available_uuids } = partition_nodes_by_availability(@dataset.id)
    
    _.each not_available_uuids, (uuid) ->
      view      = get_view(uuid)
      element   = view.$element.get(0)
      relation  = view.relation().element

      element.classList.remove('locked')
      
    cleanup_insert_positions()
    
    unless origin.droppable
      get_relation(@dataset.id).position
        cached: true  
  
  #
  # Drop activation/deactivation
  #
  
  activate_drop = ->
    $(container_selector).on "cc::drag:drop:enter", node_selector, on_node_drop_enter
    $(container_selector).on "cc::drag:drop:move", node_selector, on_node_drop_move
    $(container_selector).on "cc::drag:drop:leave", node_selector, on_node_drop_leave
    $(container_selector).on "cc::drag:drop:drop", node_selector, on_node_drop_drop
  
  deactivate_drop = ->
    $(container_selector).off "cc::drag:drop:enter", node_selector, on_node_drop_enter
    $(container_selector).off "cc::drag:drop:move", node_selector, on_node_drop_move
    $(container_selector).off "cc::drag:drop:leave", node_selector, on_node_drop_leave
    $(container_selector).off "cc::drag:drop:drop", node_selector, on_node_drop_drop
  

  # On node drop enter
  #
  
  on_node_drop_enter = (event) ->
    return if @classList.contains('locked') or @ == event.draggableTarget
    origin.droppable = @dataset.id
  
  

  # On node drop move
  #
  
  on_node_drop_move = (event) ->
    return unless origin.droppable
    
    { x, index }  = calculate_insert_position(origin.droppable, event.pageX)
    y             = @getBoundingClientRect().bottom
    
    origin.droppable_index = index

    origin.path = calculate_path(origin.relation_container, event.draggableTarget, x, y)

    get_relation(event.draggableTarget.dataset.id).position
      path: "M #{origin.path.x1} #{origin.path.y1} L #{origin.path.x2} #{origin.path.y2}" 

    

  # On node drop leave
  #
  
  on_node_drop_leave = (event) ->
    delete origin.droppable
    delete origin.droppable_index
  
  
  # On node drop drop
  #
  
  on_node_drop_drop = (event) ->
    return unless origin.droppable
    
    model = get_model(event.draggableTarget.dataset.id)
    index = model.index()
    
    if model.parent_id == @dataset.id and (index == origin.droppable_index or index == origin.droppable_index - 1)
      get_relation(event.draggableTarget.dataset.id).position({ cached: true })
    else
      relation = get_relation(event.draggableTarget.dataset.id)
      relation.cached_path = origin.path
      Arbiter.publish("node:drag:drop", { uuid: model.uuid, parent_id: origin.droppable, position: origin.droppable_index })
    
    delete origin.droppable
    delete origin.droppable_index
    
    deactivate_drop()
    

#
#
#

##_.extend cc.blueprint.common,
#  activate_node_drag_drop: activate
