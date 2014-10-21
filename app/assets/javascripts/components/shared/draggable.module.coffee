Component = React.createClass

  displayName: 'Draggable'
  
  
  revert: (callback) ->
    node      = @getDOMNode()
    style     = window.getComputedStyle(node)

    start     = 0
    duration  = 300
    pageX     = (parseFloat(style.left) || 0)
    pageY     = (parseFloat(style.top)  || 0)
    
    dx = @state.startX - pageX 
    dy = @state.startY - pageY

    tick = (timestamp) =>
      start     = timestamp unless start
      progress  = timestamp - start
      delta     = Math.min(1, progress / duration)
      delta     = 1 - Math.pow(1 - delta, 3)
      
      x = dx * delta
      y = dy * delta
      
      node.style.left = pageX + x + 'px'
      node.style.top  = pageY + y + 'px'
    
      if progress < duration
        requestAnimationFrame(tick) 
      else
        callback() if _.isFunction(callback)
      
    requestAnimationFrame(tick)
        
      
  
  
  handleMouseDown: (event) ->
    event.preventDefault()
    
    node        = @getDOMNode()
    parentNode  = node.offsetParent
    
    bounds        = node.getBoundingClientRect()
    parentBounds  = parentNode.getBoundingClientRect()
    style         = window.getComputedStyle(node)
    
    clone                 = node.cloneNode(true)
    clone.style.width     = style.width
    clone.style.height    = style.height
    clone.style.position  = 'absolute'
    clone.style.left      = bounds.left - parentBounds.left - parseFloat(style.marginLeft) + 'px'
    clone.style.top       = bounds.top - parentBounds.top - parseFloat(style.marginTop) + 'px'
    
    node.parentNode.appendChild(clone)
    
    @setState
      startX:       parseFloat(clone.style.left)  || 0
      startY:       parseFloat(clone.style.top)   || 0
      offsetX:      event.pageX
      offsetY:      event.pageY
      clone:        clone
    

    clone.classList.add('draggable')
    
    
    node.style.opacity = 0


    window.addEventListener('mousemove', @handleMouseMove)
    window.addEventListener('mouseup', @handleMouseUp)
  

  handleMouseUp: (event) ->
    node = @getDOMNode()

    @state.clone.classList.remove('draggable')
    @state.clone.parentNode.removeChild(@state.clone)

    node.style.opacity = 1

    @setState
      pageX:  null
      pageY:  null
      clone:  null

    window.removeEventListener('mousemove', @handleMouseMove)
    window.removeEventListener('mouseup', @handleMouseUp)
  
  
  handleMouseMove: (event) ->
    @setState
      pageX:  event.pageX
      pageY:  event.pageY
    
    @props.onDragMove({ x: event.pageX, y: event.pageY })
  
  
  handleClick: (event) ->
  
  
  componentDidMount: ->
    node = @getDOMNode()
    
    node.addEventListener('mousedown', @handleMouseDown)
  
  
  componentWillUnmount: ->
    node = @getDOMNode()
    
    node.removeEventListener('mousedown', @handleMouseDown)

    window.removeEventListener('mousemove', @handleMouseMove)
    window.removeEventListener('mouseup', @handleMouseUp)
  
  
  getDefaultProps: ->
    onDragMove: _.noop


  getInitialState: ->
    {}
  
  
  componentDidUpdate: (prevProps, prevState) ->
    if @state.pageX and @state.pageY
      node = @state.clone
      
      unless @props.lock_x
        node.style.left = @state.startX + (@state.pageX - @state.offsetX) + 'px'

      unless @props.lock_y
        node.style.top = @state.startY + (@state.pageY - @state.offsetY) + 'px'


  render: ->
    React.Children.only(@props.children)


module.exports = Component
