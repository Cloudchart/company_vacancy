###
  Used in:

  cloud_blueprint/react/chart_preview
###

##= require ./link

# Imports
#
tag           = React.DOM
LinkComponent = cc.require('blueprint/react/chart-preview/link')


# Main Component
#
MainComponent = React.createClass


  links: ->
    @props.nodes.map (node) ->
      LinkComponent
        key:          node.uuid
        ref:          node.uuid
        colorIndex:   node.color_index


  render: ->
    (tag.svg {},
      @links()
    )


# Exports
#
cc.module('blueprint/react/chart-preview/links-container').exports = MainComponent
