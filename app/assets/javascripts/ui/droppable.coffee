@cc      ?= {}
@cc.ui   ?= {}

$         = jQuery


droppable_selector              = '[data-behaviour~="droppable"]'


started                         = false


unless Element.prototype.matches
  prefixes                  = ['webkit', 'moz', 'ms', 'o']
  name                      = 'MatchesSelector'
  found_prefix              = prefixes.filter (prefix) -> Element.prototype[prefix + name]
  Element.prototype.matches = Element.prototype[found_prefix + name] if found_prefix


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
    $(element).trigger($.Event("cc::drag:drop:enter", { pageX: event.pageX, pageY: event.pageY, dataTransfer: event.dataTransfer, draggableTarget: event.draggableTarget }))
  
  
  # Leave
  #
  leave = (element, event) ->
    $(element).trigger($.Event("cc::drag:drop:leave", { pageX: event.pageX, pageY: event.pageY, dataTransfer: event.dataTransfer, draggableTarget: event.draggableTarget }))


  # Move
  #
  move = (event) ->
    element = cached_elements[cached_elements.length - 1]
    $(element).trigger($.Event("cc::drag:drop:move", { pageX: event.pageX, pageY: event.pageY, dataTransfer: event.dataTransfer, draggableTarget: event.draggableTarget })) if element


  # Drop
  #
  drop = (event) ->
    element = cached_elements[cached_elements.length - 1]
    $(element).trigger($.Event("cc::drag:drop:drop", { pageX: event.pageX, pageY: event.pageY, dataTransfer: event.dataTransfer, draggableTarget: event.draggableTarget })) if element
  

  # On Drag Start
  #
  on_cc_drag_start = (event) ->
    selector          = "#{droppable_selector}"
    cached_elements   = []

    $document.on 'cc::drag:move', on_cc_drag_move
    $document.on 'cc::drag:end',  on_cc_drag_end
  

  # On Drag Move
  #
  on_cc_drag_move = (event) ->
    
    #element = document.elementFromPoint(event.pageX, event.pageY)
    #element = element.parentNode while element.parentNode and !element.matches(droppable_selector)
    
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
    drop(event) if event.dataTransfer.getData('captured')
    cached_elements.forEach (element) -> leave(element, event)

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
