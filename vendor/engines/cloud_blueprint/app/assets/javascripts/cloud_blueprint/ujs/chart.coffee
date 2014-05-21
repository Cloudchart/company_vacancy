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

  right_sibling = _.chain(descriptors)
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
  
  right_sibling = if right_sibling then cc.blueprint.models.Node.instances[right_sibling.uuid] else null
  
  parent:         parent
  right_sibling:  right_sibling

# Validate parent after chart sync
#
validate_node = (node) ->
  node if node instanceof cc.blueprint.models.Node and cc.blueprint.models.Node.instances[node.uuid]

# Validate right sibling after chart sync
#
validate_right_sibling = (node, parent) ->
  node if node instanceof cc.blueprint.models.Node and cc.blueprint.models.Node.instances[node.uuid] and node.parent() == parent

#
#
#

__id = 0

activate_chart = (chart, chart_view, nodes_url) ->
  $document                 = $(document)
  chart_container_selector  = 'section[data-behaviour~="chart-container"]'
  
  # Set Node load url
  #
  cc.blueprint.models.Node.load_url = nodes_url
  
  # Parent and Child for new node insertion
  #
  parent        = null
  right_sibling = null
  
  
  # Create node
  #
  
  create_node = (attributes) ->
    
    # Check parent after chart sync
    parent = validate_node(parent) || chart
    
    # Check right sibling after chart sync
    right_sibling = validate_right_sibling(right_sibling, parent)
    
    # Set parent uuid if it exists
    attributes['parent_id'] = parent.uuid unless parent == chart
    
    # Set position of right sibling or become last child of parent
    attributes['position']  = if right_sibling then right_sibling.position else parent.children().length
    
    # shift right sibling if it exists
    right_sibling.shift_right() if right_sibling
    
    # Create node
    cc.blueprint.models.Node.create(attributes)
    
    # Reposition nodes
    parent.reposition()
    
    # Cleanup parent and right sibling
    parent = right_sibling = null
  

  
  
  # Update node
  #
  update_node = (uuid, attributes) ->
    cc.blueprint.models.Node.update(uuid, attributes)
  
  # Delete node
  #
  delete_node = (uuid) ->
    cc.blueprint.models.Node.delete(uuid)
    
  
  
  # Observe node form submit
  #
  $document.on 'submit', 'form.node-form', (event) ->
    event.preventDefault()
    
    $form       = $(@)
    uuid        = $form.data('id')
    attributes  = _.reduce $form.serializeArray(), (memo, pair) ->
      if _.include(cc.blueprint.models.Node.attributes, pair.name)
        memo[pair.name] = pair.value
      memo
    , {}
    
    chart.sync( -> if uuid then update_node(uuid, attributes) else create_node(attributes) ).done -> cc.ui.modal.close()
   
  
  # Observe delete button click
  #
  $document.on 'click', 'form.node-form a[data-behaviour~="delete"]', (event) ->
    event.preventDefault()
    
    uuid = _.last(@href.split('#'))
    
    chart.sync( -> delete_node(uuid) ).done -> cc.ui.modal.close()


  # Observe clicks on chart container
  #
  $document.on 'click', chart_container_selector, (event) ->
    event.stopPropagation()

    # Calculate insertion point
    { parent, right_sibling } = calculate_insert_position(chart, $('.node', chart_container_selector), { x: event.pageX, y: event.pageY })
    
    # Request new node form
    $.ajax
      url:      "#{nodes_url}/new"
      type:     'GET'
      dataType: 'script'
  
  
  # Observe clicks on node
  #
  $document.on 'click', "#{chart_container_selector} .node", (event) ->
    event.stopPropagation()
    
    # Request edit node form
    $.ajax
      url:      "#{nodes_url}/#{@dataset.id}/edit"
      type:     "GET"
      dataType: "script"
  


#
#
#

_.extend cc.blueprint.common,
  activate_chart: activate_chart
