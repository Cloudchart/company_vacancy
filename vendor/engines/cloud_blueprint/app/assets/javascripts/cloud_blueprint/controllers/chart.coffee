@['cloud_blueprint/charts#show'] = (data) ->
  
  # Load chart data
  #
  $.ajax
    url:      data.load_url
    type:     'get'
    dataType: 'json'
    complete: (xhr) ->
      console.log xhr.responseJSON
  
  $new_vacancy_button   = $('aside.person-vacancy-filter button[data-behaviour~="new-vacancy"]')
  $new_vacancy_form     = $('#new-vacancy-form')
  
  modal_vacancy_form_selector = '.modal-overlay form.vacancy'
  
  # New vacancy button click
  #
  $new_vacancy_button.on 'click', -> cc.ui.modal($new_vacancy_form.html())
  
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
    
    
    
  


# Person/Vacancy Filter visibility
#
$ ->
  
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
