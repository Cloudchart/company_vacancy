###
  Used in:

  global call
  need to come here later
###

$ = jQuery

$ ->

  $document = $(document)
  $window   = $(window)
  

  $main_shield    = null
  
  
  create_shield = (tag) ->
    $parent = $("body > #{tag}")
    
    if $parent.css('position') != 'relative'
      $parent.css('position', 'relative')

    $('<div>')
      .css('position', 'absolute')
      .addClass('shield')
      .appendTo($parent)
      .hide()
  

  ensure_shields = ->
    return if $main_shield
    $main_shield    = create_shield('main')
  

  observe_window_clicks = (event) ->
    return if $(event.toElement).closest('header form.login').length > 0
    $('header form.login [data-behaviour~="block-toggle"]').click()
    
    
  

  # After login form show
  #
  $document.on 'toggle::after::show', 'header form.login', ->
    $('input[autofocus]', @).focus()
    $document.on 'click', observe_window_clicks
    
    ensure_shields()
    $main_shield.show()


  # After login form hide
  #
  $document.on 'toggle::after::hide', 'header form.login', ->
    @reset()
    $document.off 'click', observe_window_clicks

    ensure_shields()
    $main_shield.hide()
  

  # Form submit
  #
  $document.on 'submit', 'header form.login', (event) ->
    event.preventDefault()
    
    $form = $(@)
    
    $('button', $form).addClass('active')
    
    request = $.ajax
      url:      $form.attr('action')
      type:     $form.attr('method')
      data:     $form.serializeArray()
      dataType: 'json'
      beforeSend: cc.ui.flash.hide
    
    request.done (response) ->
      $('button', $form).removeClass('active')
      
      if response.error
        cc.ui.flash.error(response.error)
      else if response.redirect
        location.href = response.redirect
        