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
      'cc:blueprint:model:person/*'
      'cc:blueprint:model:vacancy/*'
      'cc:blueprint:model:identity/*'
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
      # Activate draggable widget
      cc.ui.draggable()

      # Activate droppable widget
      cc.ui.droppable()
    
      # Observe node draggable
      cc.blueprint.common.node_draggable(document.querySelector('section.chart'), 'div.node')
      
      # Observe identity draggable
      cc.blueprint.common.identity_draggable(document.querySelector('article.chart aside.identity-filter'), 'li')
      
      # Observe node droppable
      cc.blueprint.common.node_droppable(document.querySelector('section.chart'), 'div.node')
