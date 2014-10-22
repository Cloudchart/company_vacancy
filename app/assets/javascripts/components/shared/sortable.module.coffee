module.exports = React.createClass

  
  displayName: 'Sortable'
  
  
  handleMouseDown: (event) ->
    node = event.target
    node = node.parentNode while node and node isnt document and not node.matches(@props.selector)
    
    return if node is document
    
    event.preventDefault()

    clone         = node.cloneNode(true)
    style         = window.getComputedStyle(node)
    bounds        = node.getBoundingClientRect()
    elements      = @getDOMNode().querySelectorAll(@props.selector)
    parentNode    = node.offsetParent
    parentBounds  = parentNode.getBoundingClientRect()

    clone.style.height      = style.height
    clone.style.marginTop   = style.marginTop
    clone.style.marginLeft  = style.marginLeft
    clone.style.left        = bounds.left - parentBounds.left - (parseFloat(style.marginLeft) || 0) + 'px'
    clone.style.top         = bounds.top - parentBounds.top - (parseFloat(style.marginTop) || 0) + 'px'
    clone.style.position    = 'absolute'
    clone.style.width       = style.width

    clone.classList.add('draggable')
    delete clone.dataset.reactid
    
    node.parentNode.appendChild(clone)
    
    @setState
      clone:      clone
      originX:    parseFloat(clone.style.left) - event.pageX
      originY:    parseFloat(clone.style.top) - event.pageY
      elements:   elements
      draggable:  node
    
    
    window.addEventListener('mousemove', @handleMouseMove)
    window.addEventListener('mouseup', @handleMouseUp)
  
  
  handleMouseMove: (event) ->
    @setState
      pageX:      event.pageX
      pageY:      event.pageY
    
    
  
  
  handleMouseUp: (event) ->
    @state.clone.parentNode.removeChild(@state.clone)
    
    @setState
      draggable:  null
      clone:      null
      elements:   null
      originX:    null
      originY:    null
      pageX:      null
      pageY:      null
    
    window.removeEventListener('mousemove',   @handleMouseMove)
    window.removeEventListener('mouseup',   @handleMouseUp)
    
    @props.onDragEnd()
  
  
  componentDidMount: ->
    window.addEventListener('mousedown', @handleMouseDown)
  
  
  componentWillUnmount: ->
    window.removeEventListener('mousedown', @handleMouseDown)
    window.removeEventListener('mousemove', @handleMouseMove)
    window.removeEventListener('mouseup',   @handleMouseUp)
  
  
  componentWillReceiveProps: ->
    @setState
      elements: @getDOMNode().querySelectorAll(@props.selector)
  
  
  componentDidUpdate: ->
    if @state.clone and @state.pageX and @state.pageY

      unless @props.lockX
        @state.clone.style.left = @state.originX + @state.pageX + 'px'
      
      unless @props.lockY
        @state.clone.style.top  = @state.originY + @state.pageY + 'px'
  
  
  getDefaultProps: ->
    onChange:     _.noop
    onDragStart:  _.noop
    onDragMove:   _.noop
    onDragEnd:    _.noop


  render: ->
    React.Children.only(@props.children)
