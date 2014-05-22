@['cloud_blueprint/charts#show'] = (data) ->
  
  
  # Models namespace
  #
  models  = cc.blueprint.models
  views   = cc.blueprint.views

  models.Chart.load_url = data.load_url
  
  # Subscriptions
  #
  on_chart_sync = ->
    chart_view.render()

  Arbiter.subscribe("#{models.Chart.topic}/sync", on_chart_sync)
  
  # Initialize Chart model and Chart view
  #

  chart       = new models.Chart(data.chart);
  chart_view  = new views.Chart(chart, 'section.chart')
  
  # First load
  chart.sync()
  
  # ujs/chart
  cc.blueprint.common.activate_chart(chart, chart_view, data.nodes_url)

  # Drag/Drop
  #
  
  cc.blueprint.common.activate_node_drag_drop(chart)


  ###

  node_drag_drop_origin =
    container: $('svg', 'section.chart').get(0)
  

  

  $('section.chart').on 'cc::drag:start', 'div.node', (event) ->
    node_drag_drop_origin.relation = document.createElementNS('http://www.w3.org/2000/svg', 'path')

    node_drag_drop_origin.relation.setAttribute('fill', 'transparent')
    node_drag_drop_origin.relation.setAttribute('stroke', 'black')
    node_drag_drop_origin.relation.setAttribute('stroke-width', 1.25)

    node_drag_drop_origin.container.appendChild(node_drag_drop_origin.relation)
    
    node          = cc.blueprint.models.Node.instances[@dataset.id]
    descendants   = node.descendants() ; descendants.push(node)
    locked_uuids  = _.map descendants, 'uuid'
    
    $('div.node', 'section.chart').each ->
      if _.contains locked_uuids, @dataset.id
        @classList.add('locked')
      else
        @dataset.droppableTarget = 'node'


  $('section.chart').on 'cc::drag:move', 'div.node', (event) ->
    container_offset  = node_drag_drop_origin.container.getBoundingClientRect()
    node_offset       = @getBoundingClientRect()
    
    x1  = node_offset.left + node_offset.width / 2 - container_offset.left
    y1  = node_offset.top + node_offset.height / 2 - container_offset.top
    x2  = event.pageX - container_offset.left
    y2  = event.pageY - container_offset.top

    node_drag_drop_origin.relation.setAttribute('d', "M #{x1} #{y1} L #{x2} #{y2}")
  

  $('section.chart').on 'cc::drag:end', 'div.node', (event) ->
    node_drag_drop_origin.container.removeChild(node_drag_drop_origin.relation)

    $('div.node', 'section.chart').each ->
      @classList.remove('locked')
      @dataset.droppableTarget = ''
  

  $('section.chart').on 'cc::drag:drop:enter', (event) ->
    console.log 'entered drop zone'
  ###
  
  ###
  
  # Person/Vacancy
  cc.ui.drag_drop('aside.person-vacancy-filter ul.people-vacancies', 'li[data-behaviour~="draggable"]', {
    revert: true
  })
  
  # Node
  cc.ui.drag_drop('section.chart', 'div.node', {
    revert: true
  })



  # Initialize Person class variables
  #
  models.Person.load_url    = data.people_url

  # Initialize Vacancy class variables
  #
  models.Vacancy.load_url   = data.vacancies_url

  # Templates
  #
  vacancy_template          = new t($('#filter-vacancy-template').html())
  person_template           = new t($('#filter-person-template').html())
  

  # Render people and vacancies
  #
  render_people_and_vacancies = ->
    $container  = $('aside.person-vacancy-filter ul.people-vacancies') ; $container.empty()

    _.chain(models.Vacancy.instances).sortBy('name').each (vacancy) ->
      $container.append(vacancy_template.render(vacancy.attributes))

    _.chain(models.Person.instances).sortBy(['last_name', 'first_name']).each (person) ->
      $container.append(person_template.render(person.attributes))
    
    Arbiter.publish('cc::blueprint::filter/render')
  
  # Debouced people and vacancies render
  #
  debounced_render_people_and_vacancies = _.debounce render_people_and_vacancies, 200


  # Subscribe on people
  #
  Arbiter.subscribe "#{models.Person.topic}/*", debounced_render_people_and_vacancies

  # Subscribe on vacancies
  #
  Arbiter.subscribe "#{models.Vacancy.topic}/*", debounced_render_people_and_vacancies
  

  # Load Nodes
  #
  # models.Node.load()
  
  # Load People
  #
  # models.Person.load()
  
  # Load Vacancies
  #
  # models.Vacancy.load()
  ###


  #
  #
  #
  
  modal_form_selector = '.modal-overlay form.person, .modal-overlay form.vacancy'
  
  # Escape button
  #
  $(document).on 'keydown', modal_form_selector, (event) ->
    cc.ui.modal.close() if event.keyCode == 27
  

  # Form validation
  #
  $(document).on 'input', modal_form_selector, ->
    
    $requires = $('*:required', modal_form_selector)
    $button   = $('button', modal_form_selector)

    form_valid  = _.chain($requires).map((input) -> $(input).val()).every((value) -> value.length > 0).value()
    
    $button.prop('disabled', !form_valid)
    
