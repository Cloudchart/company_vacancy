@['cloud_blueprint/charts#show'] = (data) ->

  # Namespaces
  #
  models  = cc.blueprint.models
  views   = cc.blueprint.views
  
  
  # Chart class variables
  #
  
  models.Chart.load_url     = data.load_url
  models.Node.load_url      = data.nodes_url
  models.Person.load_url    = data.people_url
  models.Vacancy.load_url   = data.vacancies_url
  
  
  # Initialize chart model
  #
  chart = new models.Chart(data.chart)
  
  
  # Subscribe on chart sync broabcast
  #

  on_sync = ->
    filter_view.render() if filter_view?
    chart_view.render() if chart_view?
    
  
  Arbiter.subscribe('blueprint:dispatcher/sync', on_sync)


  # Initial Sync
  #
  chart.pull().done cc.blueprint.dispatcher.sync
  

  # Initialize views
  #

  chart_view  = new views.Chart(chart, 'section.chart')
  filter_view = new views.FilterIdentityList('aside.person-vacancy-filter ul.people-vacancies')
  
  
  # Elements
  #
  $document               = $(document)
  $chart_container        = $('section.chart')
  node_selector           = '[data-behaviour~="node"]'
  node_form_selector      = ".modal-container form.node"
  delete_button_selector  = 'a[data-behaviour~="delete"]'
  
  # Observe public events
  #
  
  # chart drag
  
  
  # Observe private events
  #
  
  # chart click
  $chart_container.on 'click', cc.blueprint.common.on_chart_click
  
  # node click
  $chart_container.on 'click', node_selector, cc.blueprint.common.on_node_click
  
  # node form submit
  $document.on 'submit', node_form_selector, cc.blueprint.common.on_node_form_submit
  
  # node form delete button click
  $document.on 'click', "#{node_form_selector} #{delete_button_selector}", cc.blueprint.common.on_node_form_delete_button_click
  
  # node dropped
  $chart_container.on 'node::drop', node_selector, (event, data) ->
    model         = cc.blueprint.models.Node.get(@dataset.id)
    parent_model  = cc.blueprint.models.Node.get(data.parent.dataset.id)

    model.update
      parent_id:  parent_model.uuid
      position:   data.index - .5
  
  
  # Node drag/drop
  #
  cc.ui.droppable()
  
  # activate
  
  cc.blueprint.common.activate_node_drag_drop($chart_container, node_selector)
