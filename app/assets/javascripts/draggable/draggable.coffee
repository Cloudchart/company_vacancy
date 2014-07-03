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
  dragImageBounds = dragImage.getBoundingClientRect()
  elementBounds   = element.getBoundingClientRect()
  elementStyle    = window.getComputedStyle(element)
  dx              = dragImageBounds.left  - elementBounds.left  + parseFloat(elementStyle.marginLeft)
  dy              = dragImageBounds.top   - elementBounds.top   + parseFloat(elementStyle.marginTop)
  

  position = (x, y) ->
    dragImage.style.left  = dragImageBounds.left  - x + window.pageXOffset  + 'px'
    dragImage.style.top   = dragImageBounds.top   - y + window.pageYOffset  + 'px'
  

  tick = (timestamp) ->
    start     = timestamp unless start
    progress  = timestamp - start
    delta     = Math.min(1, progress / duration)
    
    delta     = 1 - Math.pow(1 - delta, 3) # qubic easing
    
    x         = Math.floor(dx * delta)
    y         = Math.floor(dy * delta)
    
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
    bounds            = capturedTarget.getBoundingClientRect()
    style             = window.getComputedStyle(capturedTarget, null)

    dataTransfer.setDragImage dragImage,
      event.pageX - bounds.left + parseFloat(style.marginLeft),
      event.pageY - bounds.top  + parseFloat(style.marginTop)
  

# On drag move
#
onDragMove = (capturedTarget, originalEvent, dataTransfer) ->
  customEvent   = dispatchEvent('move', capturedTarget, originalEvent, dataTransfer) ; return if customEvent.defaultPrevented

  if (dragImage = dataTransfer.dragImage) and dragImage.element
    dragImage.element.style.left  = event.pageX - dragImage.x + window.pageXOffset + 'px'
    dragImage.element.style.top   = event.pageY - dragImage.y + window.pageYOffset + 'px'


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
