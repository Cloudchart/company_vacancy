##= require ./node
##= require react_components/mixins/draggable

# Imports
#
tag             = React.DOM
NodeComponent   = cc.require('blueprint/react/chart-preview/node')
DraggableMixin  = cc.require('react/mixins/draggable')


# Main Component
#
MainComponent = React.createClass


  mixins: [DraggableMixin]
  
  
  onCCDragStart: (event) ->
    event.dataTransfer.setDragImage(false)
    
    nodeStyle = window.getComputedStyle(@getDOMNode())
    
    @__origin =
      pageX:  event.pageX
      pageY:  event.pageY


  onCCDragMove: (event) ->
    node          = @getDOMNode()
    nodeBounds    = node.getBoundingClientRect()
    nodeStyle     = window.getComputedStyle(node)
    parentBounds  = node.parentNode.getBoundingClientRect()
    parentStyle   = window.getComputedStyle(node.parentNode)
    
    dx    = @__origin.pageX - event.pageX
    dy    = @__origin.pageY - event.pageY
    
    realX = parseFloat(nodeStyle.left)  - dx
    realY = parseFloat(nodeStyle.top)   - dy

    minX = 0
    minY = 0
    maxX = parentBounds.width   - nodeBounds.width  - parseFloat(parentStyle.borderLeftWidth) - parseFloat(parentStyle.borderRightWidth)
    maxY = parentBounds.height  - nodeBounds.height - parseFloat(parentStyle.borderTopWidth)  - parseFloat(parentStyle.borderBottomWidth)
    
    x = Math.min(Math.max(maxX, realX), minX)
    y = Math.min(Math.max(maxY, realY), minY)
    
    node.style.left = x + 'px'
    node.style.top  = y + 'px'
    
    @__origin.pageX = event.pageX
    @__origin.pageY = event.pageY
    
    
  
  nodes: ->
    @props.nodes.map (node) =>
      node.key            = node.uuid
      node.ref            = node.uuid
      node.url            = @props.url
      node.children_count = @props.nodes.filter((n) -> n.parent_id == node.uuid).length
      
      NodeComponent(node)


  render: ->
    (tag.div {
      className:          'blueprint-chart-preview'
      'data-draggable':   'on'
      style:
        '-webkit-transform':  "scale(#{@props.scale})"
        '-moz-transform':     "scale(#{@props.scale})"
        '-ms-transform':      "scale(#{@props.scale})"
        transform:            "scale(#{@props.scale})"
    },
      @props.children
      @nodes()
    )


# Exports
#
cc.module('blueprint/react/chart-preview/nodes-container').exports = MainComponent
