# Defaults
#
defaults =
  distance: 3


# State
#
state = {}


# Callbacks
#
registered_callbacks =
  start:  []
  move:   []
  end:    []


# Find element valid for drag
#
findValidElementForDrag = (element) ->
  element = element.parentNode while element.parentNode and element.dataset.draggable != 'on'
  element = null if element == document
  element
  


# Check if distance is valid for drag
#
is_distance_valid = (event) ->
  dx = event.pageX - state.capturedEvent.pageX
  dy = event.pageY - state.capturedEvent.pageY
  
  Math.sqrt(dx ** 2 + dy ** 2) >= defaults.distance


# Dispatch event
#
dispatchEvent = (type, originalEvent) ->
  originalEvent.deltaX = originalEvent.pageX - state.capturedEvent.pageX
  originalEvent.deltaY = originalEvent.pageY - state.capturedEvent.pageY

  registered_callbacks[type].forEach (callback) -> callback(state.capturedTarget, originalEvent, state.dataTransfer)


# On mouse down
#
onMouseDown = (event) ->
  # Do not start drag if it has already started
  return if state.captured == true
  
  # Do not start drag if it is not standard mouse button
  return unless event.button == 0
  
  # Find target for drag
  draggableTarget = findValidElementForDrag(event.target)
  
  # Do not start drag if draggable element not found
  return unless draggableTarget
  
  # Initialize state for current drag
  state                 = {}
  state.capturedEvent   = event
  state.capturedTarget  = draggableTarget
  state.dataTransfer    = new cc.ui.drag_drop_data_transfer

  # Prevent default mouse down behaviour
  event.preventDefault()
  
  # Capture mouse move event
  document.addEventListener('mousemove', onMouseMove)
  
  # Capture mouse up event
  document.addEventListener('mouseup', onMouseUp)


# On mouse move
#
onMouseMove = (event) ->
  if state.captured
    # Dispatch on drag move event
    dispatchEvent('move', event)

  else if is_distance_valid(event)
    # Dispatch on drag start event
    dispatchEvent('start', event)

    # Set captured state
    state.captured = true    


# On mouse up
#
onMouseUp = (event) ->
  if state.captured
    # Dispatch on drag end event
    dispatchEvent('end', event)

    # Prevent click event
    event.target.addEventListener('click', onClick)
  
  # Release mouse move event
  document.removeEventListener('mousemove', onMouseMove)
  
  # Release mouse up event
  document.removeEventListener('mouseup', onMouseUp)
  
  # Cleanup state for current drag
  state = {}


# On click
#
onClick = (event) ->
  # Prevent default click behaviour
  event.preventDefault()
  
  # Stop event propagation for previous event listeners
  event.stopPropagation()
  
  # Release click event
  event.target.removeEventListener('click', onClick)


# Capture mouse down event
#
document.addEventListener('mousedown', onMouseDown)


# Provide interface for event registering
#
cc.ui.mouse_draggable =
  register: (callbacks = {}) ->
    ['start', 'move', 'end'].forEach (name) ->
      registered_callbacks[name].push(callbacks[name]) if callbacks[name] instanceof Function
