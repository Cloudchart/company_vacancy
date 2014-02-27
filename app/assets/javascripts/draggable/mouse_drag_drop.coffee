@cc    ?= {}
@cc.ui ?= {}

$       = jQuery


default_options =
  distance: 3


#
#
#

widget = ($element, selector, options = {}) ->
  
  
  options = $.extend {}, default_options, options
  
  
  ['on_drag_start', 'on_drag_move', 'on_drag_end'].forEach (callback) ->
    options[callback] = $.noop unless options[callback] and typeof options[callback] == 'function'
  

  self = {}
  
  
  # Check if distance valid
  #
  distance_valid = (event) ->
    dx = event.pageX - self.captured_event.pageX
    dy = event.pageY - self.captured_event.pageY

    Math.sqrt(dx * dx + dy * dy) >= options.distance
    

  # Mouse down
  #
  
  on_mouse_down = (event) ->
    return if self.captured
    
    button = event.button
    
    return if button and button != 0 and button != 1
    
    event.preventDefault()
    
    self.captured_event = event

    if distance_valid(event)
      on_drag_start(self.captured_event)
    
    $element.on 'mousemove',  on_mouse_move
    $element.on 'mouseup',    on_mouse_up
    
  

  # Mouse move
  #
  on_mouse_move = (event) ->
    if self.captured
      on_drag_move(event)
    else if distance_valid(event)
      on_drag_start(self.captured_event)
      on_drag_move(event)
  

  # Mouse up
  #
  on_mouse_up = (event) ->
    $element.off 'mousemove', on_mouse_move
    $element.off 'mouseup',   on_mouse_up
    
    if self.captured
      on_drag_end(event)
    
    self = {}
  

  # On drag start
  #
  on_drag_start = (event) ->
    return if self.captured

    self.captured = true
    
    options['on_drag_start'](event)
    

  # On drag move
  #
  on_drag_move = (event) ->
    options['on_drag_move'](event)
    
      

  # On drag end
  #
  on_drag_end = (event) ->
    options['on_drag_end'](event)


  #
  # Listen on mouse and touch events
  #
  
  capture = ->
    $element.on 'mousedown', selector, on_mouse_down
  

  #
  # Start
  #
  
  capture()
  

#
#
#

@cc.ui.mouse_drag_drop = widget
