NodeModel = null

#
#
#


class Node extends cc.blueprint.models.Element
  
  @className: 'Node'

  @attr_accessor  'uuid', 'chart_id', 'parent_id', 'title', 'position', 'knots'

  @element_type:  'chart'
  
  @instances:           {}
  @deleted_instances:   []
  @created_instances:   []
  

  # Create node
  #
  @create: (attributes = {}) ->
    attributes.uuid = @uuid()
    node = new @(attributes)
    @created_instances.push(node.uuid)
    @sync()
    node
    
    
  @sync: ->
    # Consolidate charts
    _.invoke cc.blueprint.models.Chart.instances, 'consolidate'

    # Save created/updated/deleted instances
    _.chain(@instances)
      .filter((instance) -> instance.is_changed() or instance.is_new_record() or instance.is_deleted())
      .invoke('save')
    
    # Sync dispatcher
    cc.blueprint.dispatcher.sync()
      
    

  consolidate: ->
    self = @

    _.chain(NodeModel.instances)
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
  

  # Update
  #
  update: (attributes = {}) ->
    super(attributes)
    @constructor.sync()
  

  # Destroy
  #
  destroy: ->
    super()
    @constructor.sync()


  # Save node
  #
  save: ->
    [url, type] = if @is_deleted()
      ["#{@constructor.load_url}/#{@uuid}", "DELETE"]
    else if @is_new_record()
      ["#{@constructor.load_url}", "POST"]
    else
      ["#{@constructor.load_url}/#{@uuid}", "PUT"]
    
    xhr = $.ajax
      url:      url
      type:     type
      dataType: "json"
      data:
        node: @attributes
    
    xhr.done (data) =>
      
      switch type
        when "POST"
          @set_attributes(data)
          @constructor.created_instances = _.without(@constructor.created_instances, @uuid)
          @synchronize()

        when "PUT"
          @set_attributes(data)
          @synchronize()

        when "DELETE"
          delete @constructor.instances[@uuid]
          @constructor.deleted_instances = _.without(@constructor.deleted_instances, @uuid)
    

    xhr.fail =>

#
#
#

_.extend cc.blueprint.models,
  Node: Node


$ ->
  NodeModel = cc.blueprint.models.Node
