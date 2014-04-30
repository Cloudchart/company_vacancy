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
  
  
  # Observe vacancy clicks
  #
  $document.on 'click', 'aside.person-vacancy-filter li.vacancy', (event) ->
    $.ajax
      url:      "#{cc.blueprint.models.Vacancy.load_url}/#{@dataset.id}/edit"
      type:     'GET'
      dataType: 'script'


  # Observe new vacancy button click
  #
  $document.on 'click', 'aside.person-vacancy-filter button[data-behaviour~="new-vacancy"]', (event) ->
    new cc.ui.modal($('#new-vacancy-form').html())
