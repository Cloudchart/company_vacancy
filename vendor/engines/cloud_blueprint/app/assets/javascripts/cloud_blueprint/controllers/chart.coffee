@['cloud_blueprint/charts#show'] = (data) ->

  models = cc.blueprint.models


  # Initialize Vacancy class variables
  #
  models.Vacancy.load_url  = data.vacancies_url
  models.Vacancy.template  = new t($('#filter-vacancy-template').html())
  

  # Render people and vacancies
  #
  render_people_vacancies = ->
    $container  = $('aside.person-vacancy-filter ul.people-vacancies') ; $container.empty()
    _.chain(models.Vacancy.instances).sortBy('name').each (vacancy) -> $container.append(vacancy.render())


  # Subscribe on vacancies
  #
  Arbiter.subscribe "#{models.Vacancy.topic}/*", _.debounce(render_people_vacancies, 100)
  

  # Load Vacancies
  #
  models.Vacancy.load()


  # Vacancies DataSource
  # vacancies_data_source = cc.blueprint.datasources.vacancies(data.vacancies_url)
  
  # Render vacancies
  #$.when(vacancies_data_source).then ->
  #  $container        = $('aside.person-vacancy-filter ul.people-vacancies')
  #  
  #  _.each vacancies_data_source, (data) -> new models.Vacancy(data)
  #
  #  _.each models.Vacancy.instances, (vacancy) -> $container.append(vacancy.render())
    
    
  
  #
  #
  #
  
  modal_vacancy_form_selector = '.modal-overlay form.vacancy'
  
  # Escape button
  #
  $(document).on 'keydown', modal_vacancy_form_selector, (event) ->
    cc.ui.modal.close() if event.keyCode == 27
  
  # Form validation
  #
  $(document).on 'input', "#{modal_vacancy_form_selector}", ->
    
    $requires = $('*:required', modal_vacancy_form_selector)
    $button   = $('button', modal_vacancy_form_selector)

    form_valid  = _.chain($requires).map((input) -> $(input).val()).every((value) -> value.length > 0).value()
    
    $button.prop('disabled', !form_valid)
    
