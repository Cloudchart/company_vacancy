NodeModel = null

#
#
#

class Chart extends cc.blueprint.models.Element
  
  @attr_accessor 'uuid', 'title'
  
  @element_type: 'chart'
  
  @instances:           {}
  @deleted_instances:   []
  @created_instances:   []
  
  
  # Pull
  #
  pull: ->
    self      = @
    deferred  = new $.Deferred
    
    $.ajax
      url:        "#{@constructor.load_url}/pull"
      type:       "GET"
      dataType:   "JSON"
      data:
        last_accessed_at: + @last_accessed_at || 0
    
    .done (data) ->
      # Process data
      self.process_pull(data)
      
      # Resolve deferred
      deferred.resolve()
      
      # Broadcast
      Arbiter.publish('blueprint:chart/sync')
    
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
    
    # Instantiate nodes
    cc.blueprint.models.Node.instantiate(data.nodes, data.available_nodes)
    @consolidate()
  
  
  # Push
  #
  push: ->
    deferred  = new $.Deferred
    self      = @
    
    people_pushed = cc.blueprint.models.Person.push("#{@constructor.load_url}/people")
    
    $.when(people_pushed).done ->
      deferred.resolve()
    
    deferred.promise()
  
  
  # Sync
  #
  sync: (callback) ->
    deferred  = new $.Deferred
    self      = @
    
    self.pull().done ->
      self.push().done ->
        self.pull().done ->
          deferred.resolve()
    
    deferred.promise()
  

  # Consolidate
  #
  consolidate: ->
    self  = @

    _.chain(NodeModel.instances)
      # Find nodes of current chart
      .filter((node) -> !node.is_deleted() and node.chart_id == self.uuid)
      # Filter nodes without parent
      .reject((node) -> NodeModel.get(node.parent_id))
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

$ ->
  NodeModel ||= cc.blueprint.models.Node