$ ->

  $document = $(document)

  # Toggle filter visibility
  #

  $filter       = $('aside.person-vacancy-filter')
  $button       = $('button.toggle', $filter)
  $button_icon  = $('i.fa', $button)
  
  $button.on 'click', (event) ->
    
    position  = parseFloat($filter.css('left'))
    width     = parseFloat($filter.css('width'))

    $filter.velocity
      left: if position < 0 then 0 else width * -1
    , 200, 'easeOutQuad'
    
    _.each $button.data('toggle').split('|'), (state) -> $button_icon.toggleClass(state)
  

  # Store last performed query
  #
  performed_query = ''
  

  # Perform last search
  #
  perform_last_search = ->
    query           = performed_query
    performed_query = null
    if query == '' then reset_search() else perform_search(query)
  

  # Subscribe on filter render
  #
  Arbiter.subscribe 'cc::blueprint::filter/render', perform_last_search


  # Reset search
  #
  reset_search = ->
    return if performed_query == ''
    performed_query = ''
    $('aside.person-vacancy-filter ul.people-vacancies > li').each -> $(@).removeClass('hidden')
  
  
  # Perform search
  #
  perform_search = (query) ->
    return if performed_query == query
    performed_query = query
    
    queries = query.split(' ')
    
    people      = _.values cc.blueprint.models.Person.instances
    vacancies   = _.values cc.blueprint.models.Vacancy.instances
    
    _.each queries, (part) ->
      re          = new RegExp(part, 'gi')
      people      = _.filter people,    (person)  -> person.matches(re)
      vacancies   = _.filter vacancies, (vacancy) -> vacancy.matches(re)
    
    ids = []
    ids.push(_.map(people, 'uuid')...)
    ids.push(_.map(vacancies, 'uuid')...)
    
    $('aside.person-vacancy-filter ul.people-vacancies > li').each ->
      $el = $(@)
      $el.toggleClass('hidden', !_.include(ids, $el.data('id')))
  

  # Observe search field input
  #
  $document.on 'input', 'aside.person-vacancy-filter input.search', (event) ->
    $el   = $(@)
    query = $.trim($el.val())
    if query == '' then reset_search() else perform_search(query)
  
  
  # Observe person clicks
  #
  $document.on 'click', 'aside.person-vacancy-filter li.person', (event) ->
    $.ajax
      url:      "#{cc.blueprint.models.Person.load_url}/#{@dataset.id}/edit"
      type:     'GET'
      dataType: 'script'


  # Observe vacancy clicks
  #
  $document.on 'click', 'aside.person-vacancy-filter li.vacancy', (event) ->
    $.ajax
      url:      "#{cc.blueprint.models.Vacancy.load_url}/#{@dataset.id}/edit"
      type:     'GET'
      dataType: 'script'


  # Observe new person button click
  #
  $document.on 'click', 'aside.person-vacancy-filter button[data-behaviour~="new-person"]', (event) ->
    new cc.ui.modal($('#new-person-form').html())


  # Observe new vacancy button click
  #
  $document.on 'click', 'aside.person-vacancy-filter button[data-behaviour~="new-vacancy"]', (event) ->
    new cc.ui.modal($('#new-vacancy-form').html())
