@cc ?= {}

$ = jQuery


defaults =
    helper: 'clone'
  


helpers = 
  clone: ($element, options = {}) ->
    $helper = $element.clone().removeAttr('id').appendTo($element.parent())

    $helper.css('position', 'absolute')
    $helper.height($element.height())
    $helper.width($element.width())
    $helper.addClass('drag')
    
    $helper


positioned_parent = (element) ->
  while element = element.parentNode
    style = window.getComputedStyle(element)
    break unless style
    break if style.position == 'static'
  element
    

scroll_parent = (element) ->
  position = window.getComputedStyle(element).position
  
  loop
    break unless element.parentNode
    
    style = window.getComputedStyle(element)
    
    break unless style
    
    unless style.position == 'static' and position == 'absolute'
      break if (/(auto|scroll)/).test [
        style.overflow
        style.overflowX
        style.overflowY
      ].join('')
    
    element = element.parentNode
  
  if element == document then document.body else element


#
#
#

#
#
#


touchdrag = (element_or_selector, options = {}) ->
    
    options = $.extend {}, defaults, options
    

    $element    = null
    $helper     = null
    
    origin      = {}

    #
    # Drag start
    #
    start = (event) ->
      origin    = {}
      $element  = $(event.currentTarget).addClass('active')
      $helper   = helpers[options.helper]($element)
      
      origin.helper_parent    = $helper.parent()
      
      origin.positioned_parent  = positioned_parent($helper[0])
      
      origin.offset           = $element.offset()
      origin.parent_offset    = $helper.parent().offset()
      
      origin.anchor =
        left: event.pageX - origin.offset.left
        top:  event.pageY - origin.offset.top
      
      $helper.offset
        left: origin.offset.left
        top:  origin.offset.top
        
      origin.pointer_events = $helper.css('pointer-events')
    

    #
    # Drag
    #
    drag = (event) ->
      $helper.offset
        left: event.pageX - origin.anchor.left
        top: event.pageY - origin.anchor.top
      
      $helper.css('pointer-events', 'none')

      x = event.pageX - window.scrollX
      y = event.pageY - window.scrollY
  
      captured = document.elementFromPoint(x, y)
      
      if captured?
        unless (captured_scrollable = scroll_parent(captured)) == origin.scrollable
          origin.scrollable = captured_scrollable
      
      $helper.css('pointer-events', origin.pointer_events)
      
       
        
      
      
    #
    # Drag stop
    #
    stop = (event) ->
      element_offset  = $element.offset()
      helper_offset   = $helper.offset()
      
      dl              = element_offset.left - helper_offset.left
      dt              = element_offset.top - helper_offset.top
      
      $helper.animate
        left: (if dl < 0 then '-' else '+') + '=' + Math.abs(dl) + 'px'
        top:  (if dt < 0 then '-' else '+') + '=' + Math.abs(dt) + 'px'
      ,
        duration: 250
        complete: ->
          $helper.remove()

      $element.removeClass('active')
    
    
    mouse_or_touch = cc.mouse_or_touch element_or_selector,
        start:  start
        drag:   drag
        stop:   stop
    
    
    null
       
    
#
#
#


@cc.touchdrag = touchdrag
