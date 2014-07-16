##= require ./node

# Imports
#
tag           = React.DOM
NodeComponent = cc.require('blueprint/react/chart-preview/node')


# Main Component
#
MainComponent = React.createClass


  nodes: ->
    @props.nodes.map (node) =>
      node.key            = node.uuid
      node.ref            = node.uuid
      node.url            = @props.url
      node.children_count = @props.nodes.filter((n) -> n.parent_id == node.uuid).length
      
      NodeComponent(node)


  render: ->
    (tag.div {
      className:  'blueprint-chart-preview'
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
