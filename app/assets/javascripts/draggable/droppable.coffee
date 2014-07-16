# Element.prototype.matches
#
['webkit', 'moz', 'ms', 'o'].forEach (vendor) ->
  return if Element.prototype.matches
  Element.prototype.matches = Element.prototype["#{vendor}MatchesSelector"]


# Captured droppable
#
capturedDroppable = null


# Dispatch event
#
dispatchEvent = (type, capturedTarget, originalEvent, dataTransfer) ->
  event = new CustomEvent "cc:drop:#{type}",
    bubbles:    true
    cancelable: true

  event.originalEvent = originalEvent
  event.dataTransfer  = dataTransfer
  event.pageX         = originalEvent.pageX
  event.pageY         = originalEvent.pageY
  
  capturedTarget.dispatchEvent(event)
  
  event


# On drag start
#
onDragStart = (capturedTarget, originalEvent, dataTransfer) ->


# On drag move
#
onDragMove = (capturedTarget, originalEvent, dataTransfer) ->
  dataTransfer.clearData('_is_captured')

  storedPointerEventStyle = null

  if dragImage = dataTransfer.dragImage.element
    storedPointerEventsStyle      = dragImage.style.pointerEvent
    dragImage.style.pointerEvents = 'none'
  
  target = document.elementFromPoint(event.pageX - window.pageXOffset, event.pageY - window.pageYOffset)
  target = target.parentNode while target and target.parentNode and target.dataset.droppable != 'on'
  target = null if target == document

  if dragImage = dataTransfer.dragImage.element
    dragImage.style.pointerEvents = storedPointerEventStyle
    storedPointerEventsStyle      = null
  
  if capturedDroppable == target
    customEvent = dispatchEvent('move', target, originalEvent, dataTransfer) if target
    if customEvent and customEvent.defaultPrevented
      dataTransfer.setData('_is_captured', true)
  else
    dispatchEvent('leave', capturedDroppable, originalEvent, dataTransfer) if capturedDroppable
    dispatchEvent('enter', target, originalEvent, dataTransfer) if target

  capturedDroppable = target


# On drag end
#
onDragEnd = (capturedTarget, originalEvent, dataTransfer) ->
  type = if dataTransfer.getData('_is_captured') then 'drop' else 'leave'
  dispatchEvent(type, capturedDroppable, originalEvent, dataTransfer) if capturedDroppable


# Register callbacks
#
cc.ui.mouse_draggable.register
  start:  onDragStart
  move:   onDragMove
  end:    onDragEnd
