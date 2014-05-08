@cc                    ?= {}
@cc.blueprint          ?= {}
@cc.blueprint.common   ?= {}

#
#
#


calculate_insert_position = (chart, elements, point) ->
  descriptors = _.map elements, (node) ->
    bounds = node.getBoundingClientRect()
    
    #node:   node
    uuid:   node.dataset.id
    bottom: bounds.bottom
    center: bounds.left + bounds.width / 2
    dx:     Math.min(Math.abs(point.x - bounds.left), Math.abs(point.x - bounds.right))

  parent = _.chain(descriptors)
    .reduce(
      (memo, descriptor) ->
        return memo if descriptor.bottom > point.y
        return [descriptor] if memo.length == 0 or memo[0].bottom < descriptor.bottom
        memo.push(descriptor) if memo[0].bottom == descriptor.bottom
        return memo
      , []
    )
    .reduce(
      (memo, descriptor) ->
        return descriptor unless memo
        return descriptor if descriptor.dx < memo.dx
        return memo
      , null
    )
    .value()

  parent        = if parent then cc.blueprint.models.Node.instances[parent.uuid] else chart
  children_ids  = _.map parent.children(), 'uuid'

  child         = _.chain(descriptors)
    .filter(
      (descriptor) ->
        _.contains(children_ids, descriptor.uuid)
    )
    .reduce(
      (memo, descriptor) ->
        return memo if descriptor.center < point.x
        return descriptor unless memo
        return descriptor if descriptor.center < memo.center
        return memo
      , null
        
    )
    .value()
  
  child = if child then cc.blueprint.models.Node.instances[child.uuid] else null
  
  parent: parent
  child:  child

#
#
#

activate_chart = (chart, nodes_url) ->
  $document                 = $(document)
  chart_container_selector  = 'section[data-behaviour~="chart-container"]'
  
  # Set Node load url
  #
  cc.blueprint.models.Node.load_url = nodes_url
  
  # Parent and Child for new node insertion
  #
  parent  = null
  child   = null
  
  
  # Observe node form submit
  #
  $document.on 'submit', 'form.node-form', (event) ->
    event.preventDefault()
    
    data = new FormData(@)
    
    
  
  # Observe clicks on chart container
  #
  $document.on 'click', chart_container_selector, (event) ->
    event.stopPropagation()

    { parent, child } = calculate_insert_position(chart, $('.node', chart_container_selector), { x: event.pageX, y: event.pageY })
    
    $.ajax
      url:      "#{nodes_url}/new"
      type:     'GET'
      dataType: 'script'

    # find parent node and position between siblings
    # create node
  
  
  # Observe clicks on node
  #
  $document.on 'click', "#{chart_container_selector} .node", (event) ->
    event.stopPropagation()
    
    $.ajax
      url:      "#{nodes_url}/#{@dataset.id}/edit"
      type:     "GET"
      dataType: "script"

#
#
#

_.extend cc.blueprint.common,
  activate_chart: activate_chart
