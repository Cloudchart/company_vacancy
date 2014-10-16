module.exports = React.createClass

  
  handleMouseDown: (event) ->
    @props.onMouseDown(event)
  

  handleMouseUp: (event) ->
    @props.onMouseUp(event)
  
  
  componentWillUnmount: ->
    window.removeEventListener('mousemove', @handleMouseMove)
    window.removeEventListener('mouseup', @handleMouseUp)


  getDefaultProps: ->
    axis:         'both'
    handle:       null
    cancel:       null
    grid:         null
    zIndex:       null
    onStart:      _.noop
    onStop:       _.noop
    onDrag:       _.noop
    onMouseDown:  _.noop
    onMouseUp:    _.noop


  getInitialState: ->
    dragging: false
    startX:   0
    startY:   0
    offsetX:  0
    offsetY:  0
    clientX:  @props.start.x
    clientY:  @props.start.y


  render: ->
    React.addons.cloneWithProps(React.children.only(@props.children), {
      onMouseDown:  @handleMouseDown
      onMouseUp:    @handleMouseUp
    })
