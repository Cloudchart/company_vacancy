@cc      ?= {}
@cc.ui   ?= {}

$         = jQuery


droppable_selector              = '[data-behaviour~=droppable]'
target_selector_attribute_name  = 'data-droppable-target'


started                         = false


#
#
#

widget = ->
  
  return if started ; started = true
  
  $document         = $(document)
  
  cached_elements   = []
  selector          = null
  
  
  # Partition elements
  #
  partition_elements = (event) ->
    elements          = document.querySelectorAll(selector)

    x = event.pageX - window.pageXOffset
    y = event.pageY - window.pageYOffset
    
    Array.prototype.reduce.call elements, (memo, element) ->
      bounds  = element.getBoundingClientRect()
      key     = if bounds.left < x and bounds.right > x and bounds.top < y and bounds.bottom > y then 'enter' else 'leave'
      memo[key].push(element) ; memo
    , { enter: [], leave: [] }
    

  # Enter
  #
  enter = (element, event) ->
    $(element).trigger($.Event("cc::drag:drop:enter", { pageX: event.pageX, pageY: event.pageY, draggableTarget: event.target }))
  
  
  # Leave
  #
  leave = (element, event) ->
    $(element).trigger($.Event("cc::drag:drop:leave", { pageX: event.pageX, pageY: event.pageY, draggableTarget: event.target }))


  # Move
  #
  move = (event) ->
    element = cached_elements[cached_elements.length - 1]
    $(element).trigger($.Event("cc::drag:drop:move", { pageX: event.pageX, pageY: event.pageY, draggableTarget: event.target })) if element


  # Drop
  #
  drop = (event) ->
    element = cached_elements[cached_elements.length - 1]
    $(element).trigger($.Event("cc::drag:drop:drop", { pageX: event.pageX, pageY: event.pageY, draggableTarget: event.target })) if element
  

  # On Drag Start
  #
  on_cc_drag_start = (event) ->
    return unless cc.ui.droppable.target
    
    selector          = "#{droppable_selector}[#{target_selector_attribute_name}=#{cc.ui.droppable.target}]"
    cached_elements   = []

    $document.on 'cc::drag:move', on_cc_drag_move
    $document.on 'cc::drag:end',  on_cc_drag_end
  

  # On Drag Move
  #
  on_cc_drag_move = (event) ->
    partitioned_elements = partition_elements(event)
    
    partitioned_elements.enter.forEach (element) ->
      if cached_elements.indexOf(element) < 0
        enter(element, event)

    partitioned_elements.leave.forEach (element) ->
      if cached_elements.indexOf(element) >= 0
        leave(element, event)
    
    cached_elements = partitioned_elements.enter
    
    move(event)


  # On Drag End
  #
  on_cc_drag_end = (event) ->
    drop(event)
    cached_elements.forEach (element) ->
      leave(element, event)

    $document.off 'cc::drag:move',  on_cc_drag_move
    $document.off 'cc::drag:end',   on_cc_drag_end
  
  
  #
  #
  #
  
  $document.on 'cc::drag:start', on_cc_drag_start
  

#
#
#

$.extend @cc.ui,
  droppable: widget
