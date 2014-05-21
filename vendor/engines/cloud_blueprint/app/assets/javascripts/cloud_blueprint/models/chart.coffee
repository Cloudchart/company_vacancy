class Chart extends cc.blueprint.models.Base

  @attr_accessor  'uuid', 'title'
  
  @instances:     {}
  
  @topic:         'cc::blueprint::models::chart'
  
  constructor: (attributes = {}) ->
    super(attributes)

    @element    = document.createDocumentFragment()
    @element.id = @uuid
  
  
  delete_obsolete_nodes: (available_uuids) ->
    chart_id          = @uuid

    nodes_to_destroy  = _.chain(cc.blueprint.models.Node.instances)
      .filter(
        (node) -> node.chart_id == chart_id
      )
      .reject(
        (node) -> _.contains(available_uuids, node.uuid)
      )
      .value()
      
    @__changed_sync = true if _.size(nodes_to_destroy) > 0

    _.invoke(nodes_to_destroy, 'destroy')
  
  
  instantiate_nodes: (nodes_attributes) ->
    _.each nodes_attributes, (attributes) ->
      if node = cc.blueprint.models.Node.instances[attributes.uuid]
        node.set_attributes(attributes)
      else
        new cc.blueprint.models.Node(attributes)

    @__changed_sync = true if _.size(nodes_attributes) > 0
  
  
  lock: ->
    @__locked = true
  
  unlock: ->
    @__locked = false
  
  locked: ->
    !!@__locked
    
    
  # Push tree
  #  
  push: ->
    self      = @
    deferred  = new $.Deferred

    nodes_pushed = cc.blueprint.models.Node.push(self.uuid, self.constructor.load_url)
    
    $.when(nodes_pushed).done ->
      
      # Resolve deferred
      deferred.resolve()
      
      # Broadcast message
      Arbiter.publish("#{self.constructor.topic}/push")

    deferred.promise()
  

  # Pull tree
  #
  pull: ->
    self      = @
    deferred  = new $.Deferred
    
    $.ajax
      url:        "#{self.constructor.load_url}/pull"
      type:       "GET"
      dataType:   "json"
      data:
        last_accessed_at: + self.last_accessed_at || 0
      
    .done (data) ->
      # Set last access time
      self.last_accessed_at = new Date(data.last_accessed_at)
      
      # Process nodes
      cc.blueprint.models.Node.instantiate(data.nodes)
      cc.blueprint.models.Node.remove_deleted_nodes(self.uuid, data.available_nodes)
      
      # Reposition chart
      self.reposition(true)
      
      # Set last sync time
      self.synchronized_at = new Date
      
      # Resolve deferred
      deferred.resolve()
      
      # Broadcast message
      Arbiter.publish("#{self.constructor.topic}/pull")
      
    
    .fail ->
      
    
    deferred.promise()
  

  # Sync tree
  #
  sync: (execute_after_first_pull = null) ->
    self      = @
    deferred  = new $.Deferred

    self.pull().done ->
      
      # Execute callback before push, if provided
      execute_after_first_pull() if _.isFunction(execute_after_first_pull)
      
      # Push data to server
      self.push().done ->
        
        # Pull most recent data from server
        self.pull().done ->
      
          # Resolve deferred
          deferred.resolve()
      
          # Broadcast message
          Arbiter.publish("#{self.constructor.topic}/sync")
    
    deferred.promise()
  

  synchronize: ->
    self = @
    
    deferred = new $.Deferred
    
    xhr = $.ajax
      url:      "#{self.constructor.load_url}/synchronize"
      data:
        last_accessed_at: +self.last_accessed_at || 0
      type:     'GET'
      dataType: 'json'
    
    xhr.done (data) ->
      self.last_accessed_at = new Date(data.last_accessed_at)
      
      self.__changed_sync = false
      
      #self.instantiate_nodes(data.nodes)
      cc.blueprint.models.Node.instantiate(data.nodes)
      
      #self.delete_obsolete_nodes(data.available_nodes)
      cc.blueprint.models.Node.cleanup(self.uuid, data.available_nodes)
      
      self.reposition(true)
  
      self.synchronized_at  = new Date
      
      deferred.resolve(self.__changed_sync)

      Arbiter.publish("#{self.constructor.topic}/synchronized", self.__changed_sync)
      
    deferred.promise()
  
  
  reposition: (deep = false) ->
    self = @
    
    children = _.chain(cc.blueprint.models.Node.instances)
      .filter((child) -> child.chart_id == self.uuid and !child.parent_id)
      .sortBy('position')
      .each((child) -> self.element.appendChild(child.element))
      .each((child, index) -> child.position = index ; child.reposition(deep) if deep )
  

  children: ->
    _.map @element.childNodes, (child) -> cc.blueprint.models.Node.instances[child.id]
  
  
  descendants: ->
    _.map @element.querySelectorAll('*'), (descendant) -> cc.blueprint.models.Node.instances[descendant.id]
  

#
#
#

_.extend cc.blueprint.models,
  Chart: Chart
