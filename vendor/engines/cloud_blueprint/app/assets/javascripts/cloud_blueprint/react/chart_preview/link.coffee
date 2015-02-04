
# Imports
#
tag               = React.DOM
defaultNodeColor  = 'hsl(0, 0%, 73%)'
colors            = require('utils/colors').colors ; colors.unshift(defaultNodeColor)

Layout            = cc.require('blueprint/react/chart-preview/layout/link')

# Main Component
#
MainComponent = React.createClass


  position: (position) ->
    return unless position.to.x? and position.to.y?
    
    path = Layout(position.to.x, position.to.y, position.from.x, position.from.y, position.midpoint, @props.radius)
    
    @getDOMNode().setAttribute('d', path)
  
  
  getDefaultProps: ->
    radius: 8


  render: ->
    (tag.path {
      fill:         'none'
      stroke:       colors[@props.colorIndex % colors.length]
      strokeWidth:  1.2
    })


# Exports
#
cc.module('blueprint/react/chart-preview/link').exports = MainComponent
