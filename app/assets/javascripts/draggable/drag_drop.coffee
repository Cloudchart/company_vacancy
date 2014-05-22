#= require ./mouse_drag_drop

@cc    ?= {}
@cc.ui ?= {}

$       = jQuery

#
#
#


clone_for_drag = (element, options = {}) ->
  node    = element.cloneNode(true)
  node.id = null
  
  bounds  = element.getBoundingClientRect()
  
  node.style.width    = bounds.width + 'px'
  node.style.height   = bounds.height + 'px'
  node.style.position = 'absolute'
  node.style.left     = '0px'
  node.style.top      = '0px'

  document.body.appendChild(node)
  
  node


dummy_for_drag = ->
  document.body.appendChild(document.createElement('span'))

#
#
#

widget = (element, selector, options = {}) ->
  
  $element = $(element) ; return if $element.length == 0
  
  self = {}
  
  # Element for Drag
  #
  element_for_drag = ->
    if options.helper == false
      dummy_for_drag()
    else
      clone_for_drag(self.target)
  
  
  # Revert helper to origin
  #
  revert_to_origin = ->
    $(self.element).velocity
      left: self.initial_position.x
      top:  self.initial_position.y
    ,
      duration: 200
      complete: dispose_of_element_for_drag
  
  
  # Dispose of Element for Drag
  #
  dispose_of_element_for_drag = ->
    unless self.element == self.target
      self.element.parentNode.removeChild(self.element)
  
  
  # Cache position
  #
  initial_position = (style) ->
    if self.target == self.element
      
      x: parseFloat(style.left) || 0
      y: parseFloat(style.top)  || 0

    else
      target_bounds   = self.target.getBoundingClientRect()
      element_bounds  = self.element.getBoundingClientRect()
    
      x: target_bounds.left - element_bounds.left
      y: target_bounds.top - element_bounds.top
  
  
  # Position at Left,Top
  #
  position_at_left_top = ->
    self.element.style.left = self.position.x + 'px'
    self.element.style.top  = self.position.y + 'px'
    
  
  # On Drag Start
  #
  on_drag_start = (event) ->
    if options.drop_on
      cc.ui.droppable.target = options.drop_on
    
    self = {}
    
    self.target   = event.currentTarget
    self.$target  = $(self.target)
    self.element  = element_for_drag()
    
    style         = window.getComputedStyle(self.element)

    unless (/^(abs|rel)/).exec(style.position)
      self.element.style.position = 'relative'
    
    self.initial_position = initial_position(style)
    
    self.initial_point =
      x: event.pageX
      y: event.pageY
    
    self.position =
      x: self.initial_position.x
      y: self.initial_position.y
    
    position_at_left_top()

    self.$target.trigger($.Event("cc::drag:start", { pageX: event.pageX, pageY: event.pageY }))
  
  
  # On Drag Move
  #
  on_drag_move = (event) ->
    drag =
      x: event.pageX - self.initial_point.x
      y: event.pageY - self.initial_point.y
    
    self.position =
      x: self.initial_position.x + drag.x
      y: self.initial_position.y + drag.y
      
    position_at_left_top()
    
    self.$target.trigger($.Event("cc::drag:move", { pageX: event.pageX, pageY: event.pageY }))
  
  
  # On Drag End
  #
  on_drag_end = (event) ->
    cc.ui.droppable.target = null
    if options.revert == true
      revert_to_origin()
    else
      dispose_of_element_for_drag()
    self.$target.trigger($.Event("cc::drag:end", { pageX: event.pageX, pageY: event.pageY }))


  

  # Start capturing mouse events
  #
  cc.ui.mouse_drag_drop $element, selector,
    on_drag_start:  on_drag_start
    on_drag_move:   on_drag_move
    on_drag_end:    on_drag_end


#
#
#

$.extend @cc.ui,
  drag_drop: widget
