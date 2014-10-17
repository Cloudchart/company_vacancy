###
  Used in:

  draggable/drag_drop
  shared/editable_articles
###

@cc      ?= {}
@cc.ui   ?= {}

$         = jQuery


droppable_selector              = '[data-behaviour~="droppable"]'


started                         = false


#unless Element.prototype.matches
#  prefixes                  = ['webkit', 'moz', 'ms', 'o']
#  name                      = 'MatchesSelector'
#  found_prefix              = prefixes.filter (prefix) -> Element.prototype[prefix + name]
#  Element.prototype.matches = Element.prototype[found_prefix + name] if found_prefix

['webkit', 'moz', 'ms', 'o'].forEach (vendor) ->
  return if Element.prototype.matches
  Element.prototype.matches = Element.prototype["#{vendor}MatchesSelector"]


#
#
#

widget = ->
  
  return if started ; started = true
  
  $document         = $(document)
  
  cached_element    = null
  selector          = null
  
  
  # Trigger 
  #
  trigger = (name, event) ->
    $(cached_element).trigger($.Event("cc::drag:drop:#{name}", {
      pageX:            event.pageX
      pageY:            event.pageY
      dataTransfer:     event.dataTransfer
      draggableTarget:  event.draggableTarget
    })) if cached_element
  
  
  # Enter
  #
  enter = (event) ->
    trigger('enter', event)
  
  
  # Leave
  #
  leave = (event) ->
    trigger('leave', event)


  # Move
  #
  move = (event) ->
    trigger('move', event)


  # Drop
  #
  drop = (event) ->
    trigger('drop', event)
  

  # On Drag Start
  #
  on_cc_drag_start = (event) ->
    selector          = "#{droppable_selector}"
    cached_element    = null

    $document.on 'cc::drag:move', on_cc_drag_move
    $document.on 'cc::drag:end',  on_cc_drag_end
  

  # On Drag Move
  #
  on_cc_drag_move = (event) ->

    dragImage                     = event.dataTransfer.dragImage.element
    dragImagePointerEventsStyle   = dragImage.style.pointerEvents if dragImage
    dragImage.style.pointerEvents = 'none' if dragImage
    
    element   = document.elementFromPoint(event.pageX, event.pageY)
    element   = element.parentNode while element and element.parentNode and !element.matches(selector)
    element   = null unless element and element.parentNode

    dragImage.style.pointerEvents = dragImagePointerEventsStyle if dragImage
    
    unless element == cached_element
      leave(event)
      cached_element = element
      enter(event)
    
    move(event)
    


  # On Drag End
  #
  on_cc_drag_end = (event) ->
    if event.dataTransfer.getData('captured') then drop(event) else leave(event)

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
