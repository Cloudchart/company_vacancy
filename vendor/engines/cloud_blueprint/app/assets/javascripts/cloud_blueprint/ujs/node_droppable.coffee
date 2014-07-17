#
#
#

# On enter
#
on_enter = (event) ->
  return unless event.dataTransfer
  on_node_enter(event)      if event.dataTransfer.types.indexOf('node') > -1
  on_identity_enter(event)  if event.dataTransfer.types.indexOf('identity') > -1
    

# On leave
#
on_leave = (event) ->
  return unless event.dataTransfer
  on_node_leave(event)      if event.dataTransfer.types.indexOf('node') > -1
  on_identity_leave(event)  if event.dataTransfer.types.indexOf('identity') > -1


# On move
#
on_move = (event) ->
  return unless event.dataTransfer
  on_node_move(event)     if event.dataTransfer.types.indexOf('node') > -1
  on_identity_move(event) if event.dataTransfer.types.indexOf('identity') > -1


# On drop
#
on_drop = (event) ->
  return unless event.dataTransfer
  on_node_drop(event)     if event.dataTransfer.types.indexOf('node') > -1
  on_identity_drop(event) if event.dataTransfer.types.indexOf('identity') > -1
  

#
# Node
#

insertion_points = []


# Calculate insertion points
#
calculate_insertion_points = (element, uuid) ->
  bounds            = element.getBoundingClientRect()
  children          = cc.blueprint.models.Node.get(element.dataset.id).children
  dw                = bounds.width / (children.length + 1)
  insertion_points  = _.map [0 .. children.length], (i) -> i * dw + dw / 2
  index             = _.indexOf _.map(children, 'uuid'), uuid
  
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
  uuid          = event.dataTransfer.getData('node').props.key
  denied_uuids  = [uuid, _.map(cc.blueprint.models.Node.get(uuid).descendants, 'uuid')...]
  
  event.dataTransfer.setData('captured', denied_uuids.indexOf(event.target.dataset.id) == -1)

  calculate_insertion_points(event.target, uuid)


# On node leave
#
on_node_leave = (event) ->
  event.dataTransfer.clearData('captured')
  insertion_points = []


# On node move
#
on_node_move = (event) ->
  return unless event.dataTransfer.getData('captured')

  uuid              = event.dataTransfer.getData('node').props.key
  { x }             = find_closest_insertion_point(event.target, event.pageX)
  
  relation_element  = cc.blueprint.react.Blueprint.Relation.get(uuid).getDOMNode()
  coordinates       = calculate_coordinates(event, x, relation_element)
  
  relation_element.setAttribute('d', "M #{coordinates.parent_left} #{coordinates.parent_top} L #{coordinates.child_left} #{coordinates.child_top}")


# On node drop
#
on_node_drop = (event) ->
  if event.dataTransfer.getData('captured')
  
    uuid          = event.dataTransfer.getData('node').props.key
    { x, index }  = find_closest_insertion_point(event.target, event.pageX)
  
    relation              = cc.blueprint.react.Blueprint.Relation.get(uuid)
    relation_element      = relation.getDOMNode()
    coordinates           = calculate_coordinates(event, x, relation_element)
    coordinates.midpoint  = (coordinates.parent_top + coordinates.child_top) / 2

    relation.setPosition(coordinates)

    node = cc.blueprint.models.Node.get(uuid)

    node.update
      position:   index - 0.5
      parent_id:  event.target.dataset.id
  
    Arbiter.publish("#{node.constructor.broadcast_topic()}/update")
  
    _.delay (-> cc.blueprint.models.Node.sync()), 250
  
  insertion_points = []


#
# Identity
#


# On identity enter
#
on_identity_enter = (event) ->
  node              = cc.blueprint.models.Node.get(event.target.dataset.id)
  identity_data     = JSON.parse(event.dataTransfer.getData('identity'))
  people_uuids      = node.people().map((person) -> person.uuid)
  vacancies_uuids   = node.vacancies().map((vacancy) -> vacancy.uuid)
  captured          = people_uuids.indexOf(identity_data.uuid) < 0 and vacancies_uuids.indexOf(identity_data.uuid) < 0
  
  event.dataTransfer.setData('captured', captured)
  event.target.classList.toggle('captured', captured)
  event.preventDefault()
  event.stopPropagation()
  

# On identity leave
#
on_identity_leave = (event) ->
  event.dataTransfer.clearData('captured')
  event.target.classList.remove('captured')


# On identity leave
#
on_identity_move = (event) ->
  event.preventDefault()
  event.stopPropagation()


# On identity drop
#
on_identity_drop = (event) ->
  event.stopPropagation()
  
  event.target.classList.remove('captured')

  identity_data   = JSON.parse(event.dataTransfer.getData('identity'))
  identity_model  = cc.blueprint.models[identity_data.className].get(identity_data.uuid)

  identity = cc.blueprint.models.Identity.create
    chart_id:       identity_model.chart_id
    node_id:        event.target.dataset.id
    identity_id:    identity_data.uuid
    identity_type:  identity_data.className
  
  identity.save()
  
  Arbiter.publish("#{identity.constructor.broadcast_topic()}/create")
  
  


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
