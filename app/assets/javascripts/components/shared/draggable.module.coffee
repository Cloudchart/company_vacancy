Component = React.createClass

  displayName: 'Draggable'
  
  
  revert: ->
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
      
      requestAnimationFrame(tick) if progress < duration
      
      node.style.left = pageX + x + 'px'
      node.style.top  = pageY + y + 'px'
    
    requestAnimationFrame(tick)
        
      
  
  
  handleMouseDown: (event) ->
    event.preventDefault()
    
    node = @getDOMNode()
    
    bounds  = node.getBoundingClientRect()
    style   = window.getComputedStyle(node)
    

    @setState
      startX:       parseFloat(style.left)  || 0
      startY:       parseFloat(style.top)   || 0
      offsetX:      event.pageX
      offsetY:      event.pageY
    

    node.classList.add('draggable')


    window.addEventListener('mousemove', @handleMouseMove)
    window.addEventListener('mouseup', @handleMouseUp)
  

  handleMouseUp: (event) ->
    node = @getDOMNode()

    @setState
      pageX:  null
      pageY:  null

    node.classList.remove('draggable')
      
    @revert()

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
      node = @getDOMNode()

      unless @props.lock_x
        node.style.left   = @state.pageX - @state.offsetX + @state.startX + 'px'

      unless @props.lock_y
        node.style.top    = @state.pageY - @state.offsetY + @state.startY + 'px'


  render: ->
    React.Children.only(@props.children)


module.exports = Component
