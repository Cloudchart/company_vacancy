#= require ./mouse_draggable

# Clone for drag image
#
isDragImageOwner = false

cloneForDragImage = (element) ->
  clone   = document.body.appendChild(element.cloneNode(true))
  bounds  = element.getBoundingClientRect()
  
  clone.style.height    = bounds.height + 'px'
  clone.style.width     = bounds.width  + 'px'
  clone.style.opacity   = .9
  clone.style.position  = 'absolute'
  clone.style.zIndex    = 100000
  
  clone


# Dispose clone drag image
#
disposeCloneDragImage = (element) ->
  element.parentNode.removeChild(element)


# Revert drag image
#
revertDragImage = (dragImage, element, callback = null) ->
  start           = null
  duration        = 250
  offsetBounds    = dragImage.parentNode.getBoundingClientRect()
  dragImageBounds = dragImage.getBoundingClientRect()
  elementBounds   = element.getBoundingClientRect()
  dx              = elementBounds.left  - dragImageBounds.left
  dy              = elementBounds.top   - dragImageBounds.top
  
  
  position = (x, y) ->
    dragImage.style.left  = dragImageBounds.left  + x + offsetBounds.left + 'px'
    dragImage.style.top   = dragImageBounds.top   + y + offsetBounds.top  + 'px'
  

  tick = (timestamp) ->
    start     = timestamp unless start
    progress  = timestamp - start
    delta     = Math.min(1, progress / duration)
    x         = dx * delta
    y         = dy * delta
    
    if progress <= duration
      requestAnimationFrame(tick)
      position(x, y)
    else
      position(x, y)
      callback() if callback instanceof Function
  
  requestAnimationFrame(tick)
  

# Dispatch event
#
dispatchEvent = (type, capturedTarget, originalEvent, dataTransfer) ->
  event = new CustomEvent "cc:drag:#{type}",
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
  isDragImageOwner  = false

  customEvent = dispatchEvent('start', capturedTarget, originalEvent, dataTransfer)
  
  if dataTransfer.dragImage.element == null
    isDragImageOwner  = true
    dragImage         = cloneForDragImage(capturedTarget)
    bounds            = customEvent.target.getBoundingClientRect()
    dataTransfer.setDragImage(dragImage, event.pageX - bounds.left, event.pageY - bounds.top)


# On drag move
#
onDragMove = (capturedTarget, originalEvent, dataTransfer) ->
  customEvent = dispatchEvent('move', capturedTarget, originalEvent, dataTransfer) ; return if customEvent.defaultPrevented
  
  if dragImage = dataTransfer.dragImage.element
    dragImage.style.left  = originalEvent.pageX - dataTransfer.dragImage.x + 'px'
    dragImage.style.top   = originalEvent.pageY - dataTransfer.dragImage.y + 'px'


# On drag end
#
onDragEnd = (capturedTarget, originalEvent, dataTransfer) ->
  dragImage = dataTransfer.dragImage.element
  
  cleanup = ->
    dispatchEvent('end', capturedTarget, originalEvent, dataTransfer)
    disposeCloneDragImage(dragImage) if isDragImageOwner
  
  if dataTransfer.getData('_is_captured') or !dragImage
    cleanup()
  else
    revertDragImage dragImage, capturedTarget, cleanup
    
  
# Register callbacks
#
cc.ui.mouse_draggable.register
  start:  onDragStart
  move:   onDragMove
  end:    onDragEnd
