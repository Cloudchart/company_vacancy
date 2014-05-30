@['cloud_blueprint/charts#show'] = (data) ->

  # Namespaces
  #
  models  = cc.blueprint.models
  views   = cc.blueprint.views
  
  
  # Chart class variables
  #
  
  models.Chart.load_url = data.load_url
  
  
  # Initialize chart model
  #
  chart = new models.Chart(data.chart)
  
  
  # Subscribe on chart sync broabcast
  #

  on_sync = ->
    filter_view.render()
    
  
  Arbiter.subscribe('blueprint:dispatcher/sync', on_sync)


  # Initial Sync
  #
  cc.blueprint.dispatcher.sync()
  

  # Initialize views
  #

  filter_view = new views.FilterIdentityList('aside.person-vacancy-filter ul.people-vacancies')
  
  
  # Activations
  #
  cc.blueprint.common.activate_person_vacancy_filter()
  

  ###
  
  # Models namespace
  #
  models  = cc.blueprint.models
  views   = cc.blueprint.views

  models.Chart.load_url = data.load_url
  
  # Subscriptions
  #
  on_chart_sync = ->
    chart_view.render()
    people_vacancies_filter_view.render()
    
  Arbiter.subscribe("#{models.Chart.topic}/sync", on_chart_sync)
  
  # Initialize Chart model and Chart view
  #

  chart                         = new models.Chart(data.chart);
  chart_view                    = new views.Chart(chart, 'section.chart')
  people_vacancies_filter_view  = new views.PeopleVacanciesFilter('aside.person-vacancy-filter ul.people-vacancies', {
    person_template: new t($('#filter-person-template').html())
  })
  
  # First load
  chart.sync()
  

  # ujs/chart
  cc.blueprint.common.activate_chart(chart, chart_view, data.nodes_url)


  # Node Drag/Drop
  #
  
  cc.blueprint.common.activate_node_drag_drop(chart)
  
  # Update nodes positions after drag/drop
  #
  Arbiter.subscribe "node:drag:drop", (data) ->
    chart.sync ->
      cc.blueprint.models.Node.update(data.uuid, { parent_id: data.parent_id, position: data.position - .5 })
      chart.reposition(true)
  
  
  # Person/Vacancy Drag/Drop
  #
  cc.blueprint.common.activate_person_vacancy_drag_drop()
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
    
  ###