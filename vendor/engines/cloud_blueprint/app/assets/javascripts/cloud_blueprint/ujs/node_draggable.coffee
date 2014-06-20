# Self
#
self = {}


# On drag start
#
on_start = (event) ->
  uuid                = event.target.dataset.id

  self.node           = cc.blueprint.react.Blueprint.Node.get(uuid)
  self.relation       = cc.blueprint.react.Blueprint.Relation.get(uuid)
  self.relation_node  = self.relation.getDOMNode() if self.relation

  event.dataTransfer.setData('node', self.node) if self.relation
  


# On drag move
#
on_move = (event) ->
  return unless self.relation_node
  return if event.dataTransfer.getData('captured')
  
  offset = self.relation_node.parentNode.getBoundingClientRect()

  position =
    x1: self.relation.state.child_left
    y1: self.relation.state.child_top + self.node.getHeight() / 2
    x2: event.pageX - offset.left
    y2: event.pageY - offset.top
  
  self.relation_node.setAttribute('d', "M #{position.x1} #{position.y1} L #{position.x2} #{position.y2}")


# On drag end
#
on_end = (event) ->
  self.relation.refresh() if self.relation and !event.dataTransfer.getData('captured')
  
  delete self.relation_node
  delete self.relation
  delete self.node



#
#
#

observer = (container, selector) ->
  $container = $(container)
  
  $container.on 'cc::drag:start', selector, on_start
  $container.on 'cc::drag:move',  selector, on_move
  $container.on 'cc::drag:end',   selector, on_end

#
#
#

_.extend cc.blueprint.common,
  node_draggable: observer
