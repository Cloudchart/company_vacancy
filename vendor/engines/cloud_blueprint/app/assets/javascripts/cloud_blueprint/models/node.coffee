
__id = 0

next_id = -> "new_#{++__id}"

class Node extends cc.blueprint.models.Base

  @attr_accessor  'uuid', 'chart_id', 'parent_id', 'title', 'position', 'knots'
  
  @instances:         {}
  @deleted_instances: {}
  
  @topic:         'cc::blueprint::models::node'
  
  

  @create: (attributes = {}) ->
    attributes['uuid'] = next_id()
    node = new @(attributes)
    node.new_record = true
    node
  
  
  @update: (uuid, attributes) ->
    node = @instances[uuid]

    if node
      node.set_attributes(attributes)
    
    node
  
  
  @delete: (uuid) ->
    node = @instances[uuid]
    if node
      parent = node.parent()
      node.destroy()
      @deleted_instances[node.uuid] = node
      parent.reposition()
    node
  
  
  #@instantiate: (attributes) ->
  #  self = @
  #  if _.isArray(attributes)
  #   _.each attributes, (instance_attributes) -> self.instantiate(instance_attributes)
  #  else
  #    if node = self.instances[attributes['uuid']]
  #      node.set_attributes(attributes)
  #    else
  #      node = new self(attributes)
  
  
  @cleanup_created_nodes: ->
    _.each @nodes_to_create(), (node) -> node.destroy()
  
  
  @cleanup_deleted_nodes: ->
    @deleted_instances = {}
  

  @remove_deleted_nodes: (chart_id, available_nodes_ids) ->
    nodes_to_delete = _.chain(@instances)
      .filter(
        (node) -> node.chart_id == chart_id
      )
      .reject(
        (node) -> _.contains(available_nodes_ids, node.uuid)
      )
      .invoke('destroy')
    

  @nodes_to_create: ->
    _.filter(@instances, (node) -> node.new_record)
  


  @nodes_to_update: ->
    _.filter(@instances, (node) -> !node.new_record and node.changed())
  
  
  
  @push: (chart_id, chart_url) ->
    self      = @
    deferred  = new $.Deferred
    
    nodes_to_create = _.map   self.nodes_to_create(), 'attributes'
    nodes_to_update = _.map   self.nodes_to_update(), 'attributes'
    nodes_to_delete = _.keys  self.deleted_instances
    
    $.ajax
      url:      "#{chart_url}/nodes"
      type:     "PUT"
      data:
        create_nodes: nodes_to_create
        update_nodes: nodes_to_update
        delete_nodes: nodes_to_delete
  
    .done ->
      # cleanup created nodes
      self.cleanup_created_nodes()
    
      # cleanup deleted nodes
      self.cleanup_deleted_nodes()
    
      # Resolve deferred
      deferred.resolve()
  
    .fail ->
    
    # Return promise
    deferred.promise()
  
  
  @synchronize: ->
    self      = @
    deferred  = new $.Deferred
    
    xhr = $.ajax
      url:      "#{self.load_url}"
      type:     "PUT"
      data:
        create_nodes: _.map @nodes_to_create(), 'attributes'
        update_nodes: _.map @nodes_to_update(), 'attributes'
        delete_nodes: _.keys @deleted_instances
  
    xhr.done ->
      self.cleanup_created_nodes()
      deferred.resolve()
    
    deferred.promise()
  
  
  load_url: ->
    "#{@constructor.load_url}/#{@uuid}"
  
  
  save: (attributes = {}) ->
    deferred = new $.Deferred
    
    xhr = $.ajax
      url:        "#{@load_url()}"
      type:       "PUT"
      dataType:   "JSON"
      data:
        node:     attributes
    
    xhr.done (attributes) -> deferred.resolve(attributes)
    
    deferred.promise()
  
  
  destroy: ->
    @element.parentNode.removeChild(@element) if @element.parentNode
    super()


  constructor: (attributes = {}) ->
    super(attributes)

    @element          = document.createElement('node')
    @element.id       = @uuid
    
    self = @

    Object.defineProperty @, 'people',
      get: -> _.invoke _.filter(self.identities(), (identity) -> identity.identity_type == 'Person'), 'identity'
  
  
  identities: ->
    self = @
    _.filter cc.blueprint.models.Identity.instances, (identity) -> identity.node_id == self.uuid
  
  
  #people: ->
  #  _.invoke _.filter(@identities(), (identity) -> identity.identity_type == 'Person'), 'identity'
  
  
  parent: ->
    cc.blueprint.models.Node.instances[@parent_id] || cc.blueprint.models.Chart.instances[@chart_id]
  

  index: ->
    _.indexOf @parent().children(), @
  
  reposition: (deep = false) ->
    self      = @

    children  = _.chain(cc.blueprint.models.Node.instances)
      .filter((child) -> child.parent_id == self.uuid)
      .sortBy('position')
      .each((child) -> self.element.appendChild(child.element))
      .each((child, index) -> child.position = index ; child.reposition(deep) if deep)
    

  children: ->
    _.map @element.childNodes, (child) -> cc.blueprint.models.Node.instances[child.id]
  
  
  descendants: ->
    _.map @element.querySelectorAll('*'), (descendant) -> cc.blueprint.models.Node.instances[descendant.id]


  right_sibling: ->
    @constructor.instances[@element.nextSibling.id] if @element.nextSibling
  
  
  shift_right: ->
    if sibling = @right_sibling()
      @position = sibling.position
      sibling.shift_right()
    else
      @position = @position + 1
  

#
#
#

_.extend cc.blueprint.models,
  Node: Node
