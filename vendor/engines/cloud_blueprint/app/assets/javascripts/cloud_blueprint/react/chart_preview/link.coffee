##= require colors

# Imports
#
tag               = React.DOM
defaultNodeColor  = 'hsl(0, 0%, 73%)'
colors            = cc.require('colors') ; colors.unshift(defaultNodeColor)


# Main Component
#
MainComponent = React.createClass


  position: (position) ->
    return unless position.to.x? and position.to.y?
    
    midpoint = (position.from.y + position.to.y) / 2
    
    @getDOMNode().setAttribute('d', "M #{position.from.x}, #{position.from.y + 1} C #{position.from.x} #{midpoint} #{position.to.x} #{midpoint} #{position.to.x} #{position.to.y - 1}")


  render: ->
    (tag.path {
      fill:         'none'
      stroke:       '#000'
      strokeWidth:  1.1
    })


# Exports
#
cc.module('blueprint/react/chart-preview/link').exports = MainComponent
