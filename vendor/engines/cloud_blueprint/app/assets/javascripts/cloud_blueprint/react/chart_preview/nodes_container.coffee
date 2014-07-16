##= require ./node

# Imports
#
tag           = React.DOM
NodeComponent = cc.require('blueprint/react/chart-preview/node')
Layout        = cc.require('blueprint/react/chart-preview/layout/chart')


# Main Component
#
MainComponent = React.createClass


  nodes: ->
    @props.nodes.map (node) ->
      node.key  = node.uuid
      node.ref  = node.uuid
      NodeComponent(node)


  componentDidUpdate: ->
    bounds  = @getDOMNode().getBoundingClientRect()
    layout  = Layout(@refs)

    xOffset = bounds.width / 2
    yOffset = 20
    

    Object.keys(@refs).forEach (uuid) =>
      position = layout.positions[uuid]

      @refs[uuid].position
        left: position.x + xOffset
        top:  position.y + yOffset


  render: ->
    (tag.div {
      className:  'blueprint-chart-preview'
      style:
        '-webkit-transform':  "scale(#{@props.scale})"
        '-moz-transform':     "scale(#{@props.scale})"
        '-ms-transform':      "scale(#{@props.scale})"
        transform:            "scale(#{@props.scale})"
    },
      @nodes()
      @props.children
    )


# Exports
#
cc.module('blueprint/react/chart-preview/nodes-container').exports = MainComponent
