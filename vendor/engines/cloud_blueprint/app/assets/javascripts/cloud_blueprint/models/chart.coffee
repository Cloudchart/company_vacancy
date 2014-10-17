###
  Used in:

  cloud_blueprint/controllers/chart
  cloud_blueprint/layouts/chart
  cloud_blueprint/models/node
###

class Chart extends cc.blueprint.models.Element
  
  @className: 'Chart'
  
  @attr_accessor 'uuid', 'title'
  
  @element_type: 'chart'
  
  @instances:           {}
  @deleted_instances:   []
  @created_instances:   []
  
  
  # Pull
  #
  pull: ->
    deferred  = new $.Deferred
    
    $.ajax
      url:        "#{@constructor.url}/pull"
      type:       "GET"
      dataType:   "JSON"
      data:
        last_accessed_at: + @last_accessed_at || 0
    
    .done (data) =>
      # Process data
      @process_pull(data)
      
      # Resolve deferred
      deferred.resolve()
      
      # Broadcast
      Arbiter.publish("#{@constructor.broadcast_topic()}/sync")
    
    # Return promise
    deferred.promise()
  
  
  # Process pull
  #
  process_pull: (data) ->
    # Set server last access time
    @last_accessed_at = new Date(data.last_accessed_at)
    
    # Instantiate vacancies
    cc.blueprint.models.Vacancy.instantiate(data.vacancies, data.available_vacancies)
    
    # Instantiate people
    cc.blueprint.models.Person.instantiate(data.people, data.available_people)
    
    # Instantiate identities
    cc.blueprint.models.Identity.instantiate(data.identities, data.available_identities)

    # Instantiate and consolidate nodes
    cc.blueprint.models.Node.instantiate(data.nodes, data.available_nodes)
    @consolidate()
  
  
  # Consolidate
  #
  consolidate: ->
    self  = @

    _.chain(cc.blueprint.models.Node.instances)
      # Find nodes of current chart
      .filter((node) -> !node.is_deleted() and node.chart_id == self.uuid)
      # Filter nodes without parent
      .reject((node) -> cc.blueprint.models.Node.get(node.parent_id))
      # Sort nodes by position
      .sortBy('position')
      # Set node attributes
      # Set node parent element
      # Consolidate node children
      .each((node, i) ->
        node.parent_id  = null
        node.position   = i
        self.element.appendChild(node.element)
        node.consolidate()
      )
    
    @
    
    
  

#
#
#

_.extend cc.blueprint.models,
  Chart: Chart

