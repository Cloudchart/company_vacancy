#
#
#


class Node extends cc.blueprint.models.Element
  
  @className: 'Node'

  @attr_accessor  'uuid', 'chart_id', 'parent_id', 'title', 'position', 'color_index', 'knots'

  @element_type:  'node'
  
  @instances:           {}
  @deleted_instances:   []
  @created_instances:   []
  

  @sync: ->
    # Consolidate charts
    _.invoke cc.blueprint.models.Chart.instances, 'consolidate'

    # Save created/updated/deleted instances
    _.chain(@instances)
      .filter((instance) -> instance.is_changed() or instance.is_new_record() or instance.is_deleted())
      .invoke('save')
  
  
  can_be_deleted: ->
    super() and @children.length == 0
  
  
  identities: ->
    _.filter cc.blueprint.models.Identity.instances, (identity) => !identity.is_deleted() and @uuid == identity.node_id
  
  
  people: ->
    @identities()
      .filter((identity) -> identity.identity_type == 'Person')
      .map((identity) -> cc.blueprint.models.Person.get(identity.identity_id))
  
  
  vacancies: ->
    @identities()
      .filter((identity) -> identity.identity_type == 'Vacancy')
      .map((identity) -> cc.blueprint.models.Vacancy.get(identity.identity_id))
    

  consolidate: ->
    self = @

    _.chain(@constructor.instances)
      # Filter node children
      .filter((node) -> !node.is_deleted() and node.parent_id == self.uuid)
      # Sort by node position
      .sortBy('position')
      # Set node attributes
      # Set node parent element
      # Consolidate node children
      .each((node, i) ->
        node.parent_id  = self.uuid
        node.position   = i
        self.element.appendChild(node.element)
        node.consolidate()
      )
    
    @
  

#
#
#

_.extend cc.blueprint.models,
  Node: Node
