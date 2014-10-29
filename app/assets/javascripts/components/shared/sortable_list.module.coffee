SortableListItem = require('components/shared/sortable_list_item')


cloneNode = (node) ->
  nodeStyle           = window.getComputedStyle(node)
  nodeBounds          = node.getBoundingClientRect()
  offsetParent        = node.offsetParent
  offsetParentBounds  = offsetParent.getBoundingClientRect()
  
  marginTop   = parseFloat(nodeStyle.marginTop)   || 0
  marginLeft  = parseFloat(nodeStyle.marginLeft)  || 0
  
  clone = node.cloneNode(true)
  
  delete clone.dataset.reactid
  
  clone.style.width     = nodeStyle.width
  clone.style.height    = nodeStyle.height
  clone.style.position  = 'fixed'
  
  node.parentNode.appendChild(clone)


# Exports
#
module.exports = React.createClass


  moveDraggable: ->
    if @state.clone and @state.pageX and @state.pageY
      node = @state.clone
      
      unless @props.dragLockX
        node.style.left = - @state.originX + @state.pageX - window.scrollX + 'px'
      
      unless @props.dragLockY
        node.style.top  = - @state.originY + @state.pageY - window.scrollY + 'px'


  handleMouseDown: (event) ->
    return if @props.readOnly
    
    node  = event.target
    nodes = _.reduce @refs, ((memo, child, key) -> memo[key] = child.getDOMNode() ; memo), {}
    
    node = node.parentNode while node isnt document and not node.matches('[contenteditable]') and not _.findKey(nodes, node)
    
    return unless _.findKey(nodes, node)
    
    event.preventDefault()
    
    window.addEventListener('mouseup', @handleMouseUp)

    timer = setTimeout =>
      @handleDragStart(_.findKey(nodes, node), event)
    , 250
    
    @setState
      dragTimer: timer
  
  
  handleMouseMove: (event) ->
    @setState
      pageX:  event.pageX
      pageY:  event.pageY
    
    siblingsBounds = _.reduce @refs, (memo, child, key) =>
      memo[key] = child.getDOMNode().getBoundingClientRect() unless key == @state.draggable
      memo
    , {}
    
    pageY       = event.pageY - window.scrollY
    siblingKey  = _.findKey siblingsBounds, (siblingBounds) -> siblingBounds.top < pageY and siblingBounds.bottom > pageY
    
    return unless siblingKey
    
    midpoint    = (siblingsBounds[siblingKey].top + siblingsBounds[siblingKey].bottom) / 2
    currIndex   = _.indexOf(@orderedSortables, @state.draggable)
    nextIndex   = _.indexOf(@orderedSortables, siblingKey)
    
    if currIndex < nextIndex
      nextIndex--
    
    if midpoint < pageY
      nextIndex++
    
    return if currIndex == nextIndex
    
    @props.onOrderChange(@state.draggable, currIndex, nextIndex)
    
    @refs[@state.draggable].getDOMNode().classList.add('draggable-source')
  
  
  handleMouseUp: (event) ->
    clearTimeout @state.dragTimer

    window.removeEventListener('mouseup', @handleMouseUp)
    
    return unless @state.draggable
    
    node = @refs[@state.draggable].getDOMNode()
    
    @state.clone.parentNode.removeChild(@state.clone)
    
    @refs[@state.draggable].getDOMNode().classList.remove('draggable-source')

    @setState
      clone:      null
      draggable:  null
      pageX:      null
      pageY:      null
    
    window.removeEventListener('mousemove', @handleMouseMove)

    @props.onOrderUpdate()
  
  
  handleDragStart: (key, event) ->
    node    = @refs[key].getDOMNode()
    style   = window.getComputedStyle(node)
    bounds  = node.getBoundingClientRect()
    
    clone = cloneNode(node)
    clone.classList.add(@props.draggableClass)
      
    @setState
      clone:      clone
      pageX:      event.pageX
      pageY:      event.pageY
      originX:    event.pageX - window.scrollX - bounds.left + (parseFloat(style.marginLeft) || 0)
      originY:    event.pageY - window.scrollY - bounds.top + (parseFloat(style.marginTop) || 0)
      draggable:  key
    
    @refs[@state.draggable].getDOMNode().classList.add('draggable-source')

    window.addEventListener('mousemove', @handleMouseMove)
    

  componentDidMount: ->
    window.addEventListener('mousedown', @handleMouseDown)
  
  
  componentWillUnmount: ->
    window.removeEventListener('mousedown', @handleMouseDown)
    window.removeEventListener('mousemove', @handleMouseMove)
    window.removeEventListener('mouseup', @handleMouseUp)
  
  
  componentDidUpdate: ->
    @moveDraggable()


  getDefaultProps: ->
    onOrderChange:  _.noop
    onOrderUpdate:  _.noop
    component:      React.DOM.div
    draggableClass: 'draggable'

  getInitialState: ->
    {}
  
  
  render: ->
    @orderedSortables = []

    children = React.Children.map @props.children, (child) =>
      if child instanceof SortableListItem
        @orderedSortables.push(child.props.key)
        React.addons.cloneWithProps(child, { key: child.props.key, ref: child.props.key })
      else
        child
    
    React.createElement(
      @props.component
      @props
      children
    )
