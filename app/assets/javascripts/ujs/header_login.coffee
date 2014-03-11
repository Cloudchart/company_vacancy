$ = jQuery

$ ->
  
  $document = $(document)
  $window   = $(window)
  
  
  observe_window_clicks = (event) ->
    return if $(event.toElement).closest('header form.login').length > 0
    $('header form.login [data-behaviour~="block-toggle"]').click()
    
    
  

  # After login form show
  #
  $document.on 'toggle::after::show', 'header form.login', ->
    $('input[autofocus]', @).focus()
    $document.on 'click', observe_window_clicks


  # After login form hide
  #
  $document.on 'toggle::after::hide', 'header form.login', ->
    @reset()
    $document.off 'click', observe_window_clicks


  #
  # NB: Explicit plugin
  #
  
  $document.on 'click', '[data-behaviour="block-toggle"]', (event) ->
    event.preventDefault()
    event.stopPropagation()
    
    $($(@).data('toggle')).each ->
      $el = $(@)
      $el.trigger 'toggle::before'  + if $el.is(':hidden') then '::show' else '::hide'
      $el.toggle()
      $el.trigger 'toggle::after'   + if $el.is(':hidden') then '::hide' else '::show'
