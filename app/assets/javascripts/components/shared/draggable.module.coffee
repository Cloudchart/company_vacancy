module.exports = React.createClass

  displayName: 'Draggable'
  
  
  getDefaultProps: ->
    onDragStart:      _.noop
    onDragMove:       _.noop
    onDragEnd:        _.noop
    handleSelector:   null
    cancelSelector:   null


  render: ->
    React.Children.only(@props.children)
