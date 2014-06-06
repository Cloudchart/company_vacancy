@['cloud_blueprint/charts#show'] = (data) ->
  
  # Variables
  #
  can_edit_chart = true
  
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
  
  
  # Create chart
  #
  chart = new cc.blueprint.models.Chart(data.chart)


  # Identity filter
  #
  identity_filter = cc.blueprint.react.IdentityFilter {
    subscribe_on: [
      'cc:blueprint:model:person/*'
      'cc:blueprint:model:vacancy/*'
    ]
  }
  
  # Blueprint
  #
  blueprint = cc.blueprint.react.Blueprint {},
    if can_edit_chart
      identity_filter
  

  # Initial chart data pull
  #
  chart.pull().done ->
    # Mount blueprint
    #
    React.renderComponent(blueprint, document.querySelector('main'))
    
    # Hide spinner
    #
    cc.blueprint.react.Spinner.hide()
  

  #chart.pull().done ->
  #  cc.blueprint.react.Spinner.hide()
  #  React.renderComponent(identity_filter, chart_wrapper_element)
  
  
  # Create chart html
  #
  #el        = document.createElement('div').appendChild(document.querySelector('template#chart-template'))
  #chart_el  = el.content || _.find(el.childNodes, (node) -> node.nodeType == 1)

  #chart_wrapper_element.appendChild(chart_el)
  

  

  ###
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
    identity_list_view.refresh()
    chart_view.render() if chart_view?
    
  
  Arbiter.subscribe('blueprint:dispatcher/sync', on_sync)


  # Initial Sync
  #
  chart.pull().done cc.blueprint.dispatcher.sync
  

  # Initialize views
  #

  chart_view  = new views.Chart(chart, 'section.chart')
  #filter_view = new views.FilterIdentityList('aside.person-vacancy-filter ul.people-vacancies')
  identity_list_view = React.renderComponent(cc.blueprint.react.identity_list(), document.querySelector('aside.person-vacancy-filter div.people-vacancies'))
  
  
  # Elements
  #
  $document               = $(document)
  $chart_container        = $('section.chart')
  node_selector           = '[data-behaviour~="node"]'
  node_form_selector      = ".modal-container form.node"
  color_index_selector    = "div.color-indices input"
  delete_button_selector  = 'a[data-behaviour~="delete"]'
  
  # Observe public events
  #
  
  # Observe private events
  #
  
  cc.blueprint.common.activate_person_vacancy_filter()
  
  # chart click
  $chart_container.on 'click', cc.blueprint.common.on_chart_click
  
  # node click
  $chart_container.on 'click', node_selector, cc.blueprint.common.on_node_click
  
  # node form submit
  $document.on 'submit', node_form_selector, cc.blueprint.common.on_node_form_submit
  
  # node form delete button click
  $document.on 'click', "#{node_form_selector} #{delete_button_selector}", cc.blueprint.common.on_node_form_delete_button_click
  
  # node form color index change
  $document.on 'change', "#{node_form_selector} #{color_index_selector}", cc.blueprint.common.on_node_form_color_index_change
  
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
  
  
  # Filter new identity click
  #
  $document.on 'click', ".person-vacancy-filter nav.buttons button[data-class-name=Person]", (event) ->
    event.preventDefault()
    
    model = new cc.blueprint.models[@dataset.className]
    
    cc.ui.modal '',
      after_show: (container) ->
        React.renderComponent(cc.blueprint.react.person_form({ model: model }), container)
      
      before_close: (container) ->
        React.unmountComponentAtNode(container)
  

  # Identity drag/drop
  #
  
  # Activate
  cc.blueprint.common.activate_person_vacancy_drag_drop()
  
  # Create identity
  Arbiter.subscribe "identity:node:drop", (attributes) ->
    attributes.chart_id = chart.uuid
    cc.blueprint.models.Identity.create(attributes)
    cc.blueprint.models.Node.get(attributes.node_id).touch()
    cc.blueprint.dispatcher.sync()


  # Drag over node
  $chart_container.on 'dragover', node_selector, (event) ->
    node = cc.blueprint.models.Node.get(@dataset.id)
    return unless node.title == 'Programming'
    event.originalEvent.dataTransfer.dropEffect = 'link'
    event.preventDefault()
    return false

  $chart_container.on 'drop', node_selector, (event) ->
    event.stopPropagation()
###