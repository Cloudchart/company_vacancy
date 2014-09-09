@['cloud_blueprint/charts#show'] = (data) ->
  
  ChartActionsCreator = cc.require('cc.blueprint.actions.ChartActionsCreator')
  ChartStore          = cc.require('cc.blueprint.stores.ChartStore')
  
  PersonSyncAPI       = require('utils/person_sync_api')
  VacancySyncAPI      = require('utils/vacancy_sync_api')
  NodeIdentitySyncAPI = require('cloud_blueprint/utils/node_identity_sync_api')
  
  
  # Variables
  #
  can_edit_chart  = data.editable
  isReadOnly      = !!data.editable
  
  
  # Store chart
  #
  ChartActionsCreator.receiveOne(data.chart)
  
  
  nodesIdentitiesAreLoaded = NodeIdentitySyncAPI.fetch("/charts/#{data.id}/identities")
  peopleAreLoaded = PersonSyncAPI.fetch("/charts/#{data.id}/people")
  vacanciesAreLoaded = VacancySyncAPI.fetch("/charts/#{data.id}/vacancies")
  
  
  # Chart Title Composer
  #
  if isReadOnly and (headerMountPoint = document.querySelector('[data-header-chart-title-mount-point]'))
    ChartTitleComposer = cc.require('cc.blueprint.components.chart.ChartTitleComposer')
    
    React.renderComponent(
      (ChartTitleComposer { key: data.id })
    ,
      headerMountPoint
    ) if ChartTitleComposer


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
    company_id:   data.chart.company_id
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
  Promise.all([nodesIdentitiesAreLoaded, peopleAreLoaded, vacanciesAreLoaded]).then -> chart.pull().done ->
    # Mount blueprint
    React.renderComponent(blueprint, document.querySelector('main'))
    
    # Hide spinner
    cc.blueprint.react.Spinner.hide()
    
    if can_edit_chart
      # Activate draggable widget
      cc.ui.draggable()

      # Activate droppable widget
      cc.ui.droppable()
    
      # Observe chart droppable
      cc.blueprint.common.chart_droppable(document.querySelector('section.chart'))

      # Observe node draggable
      cc.blueprint.common.node_draggable(document.querySelector('section.chart'), 'div.node')
      
      # Observe identity draggable
      cc.blueprint.common.identity_draggable(document.querySelector('article.chart aside.identity-filter'), 'li')
      
      # Observe node droppable
      cc.blueprint.common.node_droppable(document.querySelector('section.chart'), 'div.node')

      # Observe node form droppable
      cc.blueprint.common.node_form_droppable(document.querySelector('article.chart'), 'form.node li.placeholder')

