class Chart extends cc.blueprint.models.Base

  @attr_accessor  'uuid', 'title'
  
  @instances:     {}
  
  @topic:         'cc::blueprint::models::chart'
  
  constructor: (attributes = {}) ->
    super(attributes)

    @element    = document.createElement('chart')
    @element.id = @uuid
  
  
  synchronize: =>
    self = @

    xhr = $.ajax
      url:      "#{self.constructor.load_url}/synchronize"
      data:
        last_accessed_at: +self.last_accessed_at || 0
      type:     'GET'
      dataType: 'json'
    
    xhr.done (data) ->
      self.last_accessed_at = new Date(data.last_accessed_at)

      _.each data.nodes, (attributes) -> new cc.blueprint.models.Node(attributes)
  
      Arbiter.publish("#{self.constructor.topic}/synchronized")
      

  children: ->
    _.map @element.children, (child) -> cc.blueprint.models.Node.instances[child.id]
  
  
  descendants: ->
    _.map @element.querySelectorAll('*'), (descendant) -> cc.blueprint.models.Node.instances[descendant.id]
  

#
#
#

_.extend cc.blueprint.models,
  Chart: Chart
