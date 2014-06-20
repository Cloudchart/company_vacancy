@cc      ?= {}
@cc.ui   ?= {}

# Is drag started
#
started = false

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
    self.dataTransfer = new cc.ui.drag_drop_data_transfer
    self.target       = event.currentTarget

    trigger('start', event)
  

  # On drag move
  #
  on_drag_move = (event) ->
    trigger('move', event)
  
  
  # On drag end
  #
  on_drag_end = ->
    trigger('end', event)
    
    delete self.target
    delete self.dataTransfer
  
  
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
