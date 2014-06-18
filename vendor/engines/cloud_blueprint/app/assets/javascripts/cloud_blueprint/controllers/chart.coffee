@['cloud_blueprint/charts#show'] = (data) ->
  

  # Variables
  #
  can_edit_chart = true
  

  # Access functions
  #
  get_node = (uuid) ->
    cc.blueprint.react.Blueprint.Node.get(uuid)

  get_relation = (uuid) ->
    cc.blueprint.react.Blueprint.Relation.get(uuid)
    
    
    
  # Show spinner
  #
  cc.blueprint.react.Spinner.show()


  # Set load URLs
  #
  
  cc.blueprint.models.Chart.url     = data.url
  cc.blueprint.models.Person.url    = data.url + '/people'
  cc.blueprint.models.Vacancy.url   = data.url + '/vacancies'
  cc.blueprint.models.Node.url      = data.url + '/nodes'
  cc.blueprint.models.Identity.url  = data.url + '/identities'
  
  
  # Create chart model
  #
  chart = new cc.blueprint.models.Chart(data.chart)


  # Identity filter view
  #
  identity_filter_view = cc.blueprint.react.IdentityFilter {
    subscribe_on: [
      'cc:blueprint:model:person/*'
      'cc:blueprint:model:vacancy/*'
    ]
  }
  

  # Chart view
  #
  chart_view = cc.blueprint.react.Blueprint.Chart {
    root:           chart
    can_be_edited:  can_edit_chart
    subscribe_on: [
      'cc:blueprint:model:node/*'
    ]
  }
  

  # Blueprint
  #
  blueprint = cc.blueprint.react.Blueprint {},
    identity_filter_view if can_edit_chart
    chart_view
  

  # Initial chart data pull
  #
  chart.pull().done ->
    # Mount blueprint
    React.renderComponent(blueprint, document.querySelector('main'))
    
    # Hide spinner
    cc.blueprint.react.Spinner.hide()
    
    if can_edit_chart
      # Activate droppable widget
      cc.ui.droppable()
    
      # Observe node drag/drop
      observe_node_drag_drop()
      
      # Observe node droppable
      cc.blueprint.common.node_droppable(document.querySelector('section.chart'), 'div.node')
  
  
  # Node drag/drop
  #
  observe_node_drag_drop = ->
    
    cc.blueprint.common.node_drag_drop(document.querySelector('section.chart'), 'div.node')
    
    return
    
    drag = {}
    
    cc.ui.drag_drop 'section.chart', 'div.node',
      helper: false
      revert: true
      
      on_start: (element, options = {}) ->
        
        drag.node           = get_node(element.dataset.id)
        drag.relation       = get_relation(element.dataset.id)
        drag.relation_node  = drag.relation.getDOMNode() if drag.relation
        
        uuids               = _.pluck drag.node.props.model.descendants, 'uuid'
        
        cc.ui.droppable.data  =
          capture: (element) ->
            uuid = element.dataset.id
            return drag.node.key != uuid and uuids.indexOf(uuid) == -1
        

      on_move: (element, options = {}) ->
        return unless drag.relation_node
        return if cc.ui.droppable.data.captured
        
        offset = drag.relation_node.parentNode.getBoundingClientRect()
        
        position =
          x1: drag.relation.state.child_left
          y1: drag.relation.state.child_top + drag.node.getHeight() / 2
          x2: options.x - offset.left
          y2: options.y - offset.top
        
        drag.relation_node.setAttribute('d', "M #{position.x1} #{position.y1} L #{position.x2} #{position.y2}")
        

      on_end: ->
        drag.relation.refresh() if drag.relation
        drag = {}
