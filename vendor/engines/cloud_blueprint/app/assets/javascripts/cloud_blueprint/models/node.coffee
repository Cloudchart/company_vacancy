class Node extends cc.blueprint.models.Base

  @attr_accessor  'uuid', 'chart_id', 'parent_id', 'title', 'position'
  
  @instances:     {}
  
  @topic:         'cc::blueprint::models::node'
  
  
  constructor: (attributes = {}) ->
    super(attributes)

    @element    = document.createElement('node')
    @element.id = @uuid

    @attach()
  
  
  attach: ->
    return if @element.parentNode
    parent = if @parent_id then cc.blueprint.models.Node.instances[@parent_id] else cc.blueprint.models.Chart.instances[@chart_id]
    if parent
      siblings  = parent.children()
      sibling   = siblings[@position]
      if sibling
        parent.element.insertBefore(@element, sibling.element)
      else
        parent.element.appendChild(@element)
    @
  

  children: ->
    _.map @element.children, (child) -> cc.blueprint.models.Node.instances[child.id]
    
      
  

#
#
#

_.extend cc.blueprint.models,
  Node: Node
