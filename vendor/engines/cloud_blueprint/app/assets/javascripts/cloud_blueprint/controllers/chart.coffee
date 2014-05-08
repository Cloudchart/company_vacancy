@['cloud_blueprint/charts#show'] = (data) ->
  
  
  # Models namespace
  #
  models  = cc.blueprint.models
  views   = cc.blueprint.views

  models.Chart.load_url = data.load_url
  
  # Subscriptions
  #
  on_chart_synchronized = ->
    _.invoke models.Node.instances, 'attach'
    chart_view.render()
  
  Arbiter.subscribe("#{models.Chart.topic}/synchronized", on_chart_synchronized)
  
  # Initialize Chart model and Chart view
  #

  chart       = new models.Chart(data.chart);
  chart_view  = new views.Chart(chart, 'section.chart')
  
  chart.synchronize()
  
  # ujs/chart
  cc.blueprint.common.activate_chart(chart, data.nodes_url)

  ###
  # Activate modules
  #
  
  
  
  # Drag/Drop
  #
  
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
    
