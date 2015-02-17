# @cjsx React.DOM

# Utils
#
colors    = require('utils/colors')
initials  = require('utils/initials')

cx        = React.addons.classSet

module.exports = React.createClass

  displayName: 'Avatar'


  render: ->
    letters         = initials(@props.value)
    backgroundColor = colors.colors[colors.colorIndex(letters)]
    
    style =
      backgroundColor:  if @props.avatarURL then @props.backgroundColor || 'transparent' else backgroundColor
      backgroundImage:  if @props.avatarURL then "url(#{@props.avatarURL})" else "none"
    
    classes = cx(
      avatar:         true
      "image-absent": !@props.avatarURL 
    ) 

    <figure className={ classes } style={ style }>
      <figcaption>
        { letters unless @props.avatarURL }
      </figcaption>
    </figure>