# Imports
#
tag = React.DOM

Colors      = cc.require('cc.utils.Colors')
ColorIndex  = cc.require('cc.utils.Colors.Index')
Letters     = cc.require('cc.utils.Letters')

#
#
Component = React.createClass


  render: ->
    letters = Letters(@props.value)

    (tag.figure {
      style:
        backgroundColor:  @props.backgroundColor || Colors[ColorIndex(letters)]
        backgroundImage:  if @props.avatarURL then "url(#{@props.avatarURL})" else "none"
    },
      @props.children || letters unless @props.avatarURL
    )


# Exports
#
module.exports = Component
