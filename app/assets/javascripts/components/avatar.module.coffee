# @cjsx React.DOM

# Utils
#
colors    = require('utils/colors')
initials  = require('utils/initials')

# # Imports
# #
# tag = React.DOM
#
# Colors      = cc.require('cc.utils.Colors')
# ColorIndex  = cc.require('cc.utils.Colors.Index')
# Letters     = cc.require('cc.utils.Letters')
#
# #
# #
# Component = React.createClass
#
#
#   render: ->
#     letters = Letters(@props.value)
#
#     (tag.figure {
#       style:
#         backgroundColor:  @props.backgroundColor || Colors[ColorIndex(letters)]
#         backgroundImage:  if @props.avatarURL then "url(#{@props.avatarURL})" else "none"
#     },
#       @props.children || letters unless @props.avatarURL
#     )
#
#
# # Exports
# #
# module.exports = Component

module.exports = React.createClass

  displayName: 'Avatar'


  render: ->
    letters         = initials(@props.value)
    backgroundColor = colors.colors[colors.colorIndex(letters)]
    
    style =
      backgroundColor:  if @props.avatarURL then @props.backgroundColor || backgroundColor else backgroundColor
      backgroundImage:  if @props.avatarURL then "url(#{@props.avatarURL})" else "none"
    
    <figure className="avatar" style={ style }>
      <figcaption>
        { letters unless @props.avatarURL }
      </figcaption>
    </figure>