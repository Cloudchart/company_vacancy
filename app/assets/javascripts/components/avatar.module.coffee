# @cjsx React.DOM

# Utils
#
colors    = require('utils/colors')
initials  = require('utils/initials')

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
