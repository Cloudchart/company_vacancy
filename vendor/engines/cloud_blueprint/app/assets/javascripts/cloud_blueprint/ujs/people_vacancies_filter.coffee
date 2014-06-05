###
$ ->

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
###

#
# Activate filter toggle
#
activate_toggle = ->
  $filter       = $('aside.person-vacancy-filter')
  $button       = $('button.toggle', $filter)
  $button_icon  = $('i.fa', $button)
  
  $button.on 'click', (event) ->
    position  = parseFloat($filter.css('left'))
    width     = parseFloat($filter.css('width'))
    
    $filter.animate
      left: if position < 0 then 0 else - width
    ,
      duration: 250
    
    _.each $button.data('toggle').split('|'), (state) -> $button_icon.toggleClass(state)


#
# Activate person/vacancy edit
#
activate_edit = ->
  return
  
  $aside_container = $('aside.person-vacancy-filter')
  
  
  spinner = '<div class="lock"><i class="fa fa-spinner fa-spin"></i></div>'
  
  
  $(document).on 'submit', '.modal-container form', (event) ->
    if @classList.contains('person')
      attributes = $(@).serializeArray()
  
  
  # Observe new person button click
  #
  $aside_container.on 'click', 'button[data-behaviour~="new-person"]', (event) ->
    cc.ui.modal(spinner, { locked: true })
    form = cc.blueprint.models.Person.new_form()

    form.done (template) ->
      cc.ui.modal(template)
    
    form.fail ->
      cc.ui.modal.close()
      alert('fail')


  # Observe person click
  #
  #$aside_container.on 'click', 'li.person', (event) ->
  #  cc.ui.modal(spinner, { locked: true })
  #  form = cc.blueprint.models.Person.edit_form(@dataset.id)

  #  form.done (template) ->
  #    cc.ui.modal(template)
    
  #  form.fail ->
  #    cc.ui.modal.close()
  #    alert('fail')
    

  # Observe new vacancy button click
  #
  $aside_container.on 'click', 'button[data-behaviour~="new-vacancy"]', (event) ->
    cc.ui.modal(spinner, { locked: true })
    form = cc.blueprint.models.Vacancy.new_form()

    form.done (template) ->
      cc.ui.modal(template)
    
    form.fail ->
      cc.ui.modal.close()
      alert('fail')


  # Observe vacancy click
  #
  $aside_container.on 'click', 'li.vacancy', (event) ->
    cc.ui.modal(spinner, { locked: true })
    form = cc.blueprint.models.Vacancy.edit_form(@dataset.id)

    form.done (template) ->
      cc.ui.modal(template)
    
    form.fail ->
      cc.ui.modal.close()
      alert('fail')
  
  

#
# Activate filter visibility
# Activate filter search
#

activate_filter = ->
  activate_toggle()
  activate_edit()
  
  
#
#
#

identities_container_selector      = "aside.person-vacancy-filter ul.people-vacancies"
identity_selector = 'li[data-behaviour~="draggable"]'

chart_selector          = "section.chart"
node_selector           = "div.node"


activate_drag_drop = ->
  return
  
  self                  = {}
  $identities_container = $(identities_container_selector)
  $chart                = $(chart_selector)

  cc.ui.drag_drop($identities_container, identity_selector, {
    revert:   true
    drop_on:  'node'
  })
  

  activate_drop = ->
    ["enter", "leave", "drop"].forEach (name) -> $chart.on "cc::drag:drop:#{name}", node_selector, self["on_#{name}"]


  deactivate_drop = ->
    ["enter", "leave", "drop"].forEach (name) -> $chart.off "cc::drag:drop:#{name}", node_selector, self["on_#{name}"]
  

  self.on_enter = (event) ->
    @classList.add('captured')
    event.draggableTarget.setAttribute('captured', true)


  self.on_leave = (event) ->
    @classList.remove('captured')
    event.draggableTarget.removeAttribute('captured')


  self.on_drop = (event) ->
    @classList.remove('captured')
    event.draggableTarget.removeAttribute('captured')
    deactivate_drop()
    
    Arbiter.publish "identity:node:drop",
      node_id:        @dataset.id
      identity_type:  event.draggableTarget.dataset.className
      identity_id:    event.draggableTarget.dataset.id
  

  $identities_container.on "cc::drag:start", identity_selector, activate_drop
  
  null
  

_.extend cc.blueprint.common,
  activate_person_vacancy_filter: activate_filter
  activate_person_vacancy_drag_drop: activate_drag_drop
