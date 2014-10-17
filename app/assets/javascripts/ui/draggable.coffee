###
  Used in:

  cloud_blueprint/controllers/chart
###

@cc      ?= {}
@cc.ui   ?= {}

# Is drag started
#
started = false


# Revert drag image
#

revert_drag_image = (element, target, duration = 100, callback = null) ->
  
  start         = null
  offset        = element.parentNode.getBoundingClientRect()
  element_rect  = element.getBoundingClientRect()
  target_rect   = target.getBoundingClientRect()
  dx            = target_rect.left  - element_rect.left
  dy            = target_rect.top   - element_rect.top
  

  position = (x, y) ->
    element.style.left  = element_rect.left  + x + offset.left + 'px'
    element.style.top   = element_rect.top   + y + offset.top  + 'px'
  

  tick = (timestamp) ->
    start     = timestamp unless start
    progress  = timestamp - start
    delta     = progress / duration
    delta     = 1 if delta > 1
    x         = dx * delta
    y         = dy * delta
    
    if progress <= duration
      position(x, y)
      requestAnimationFrame(tick)
    else
      position(x, y)
      callback() if callback instanceof Function

  
  requestAnimationFrame(tick)

#
#
#

widget = ->
  return if started ; started = true
  
  $document   = $(document)
  self        = {}
  
  # Trigger drag event
  #
  trigger = (name, event) ->
    $(self.target).trigger($.Event("cc::drag:#{name}",
      pageX:            event.pageX
      pageY:            event.pageY
      dataTransfer:     self.dataTransfer
      draggableTarget:  self.target
    ))
  
  
  # On drag start
  #
  on_drag_start = (event) ->
    self              = {}
    self.dataTransfer = new cc.ui.drag_drop_data_transfer
    self.target       = event.currentTarget

    trigger('start', event)
  

  # On drag move
  #
  on_drag_move = (event) ->
    if element = self.dataTransfer.dragImage.element
      element.style.zIndex  = 10000
      element.style.left    = event.pageX - self.dataTransfer.dragImage.x + 'px'
      element.style.top     = event.pageY - self.dataTransfer.dragImage.y + 'px'
    
    trigger('move', event)
  
  
  # On drag end
  #
  on_drag_end = (event) ->
    if (element = self.dataTransfer.dragImage.element) and !self.dataTransfer.getData('captured')
      revert_drag_image element, self.target, 250, ->
        trigger('end', event)
    else
      trigger('end', event)
  
  
  # Observe mouse drag/drop events
  #
  cc.ui.mouse_drag_drop $document, '[data-behaviour~="draggable"]',
    on_drag_start:  on_drag_start
    on_drag_move:   on_drag_move
    on_drag_end:    on_drag_end
  

#
#
#

$.extend @cc.ui,
  draggable: widget
