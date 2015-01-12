# Imports
#
tag = React.DOM


initials      = require('utils/initials')
colors        = require('utils/colors')

acceptableFileTypes = ['image/svg+xml', 'image/jpeg', 'image/png']
acceptableFileSize  = 1024 * 1024 * 3


# Main
#
Component = React.createClass


  # On Avatar Change
  #
  onAvatarChange: (event) ->
    file = event.target.files[0]

    return unless _.contains(acceptableFileTypes, file.type)
    return unless file.size <= acceptableFileSize
    
    imageURL  = URL.createObjectURL(file)
    image     = new Image
    
    image.onload  = =>
      URL.revokeObjectURL(imageURL)
      @props.onChange(file) if _.isFunction(@props.onChange)
    
    image.onerror = =>
      URL.revokeObjectURL(imageURL)
    
    image.src = imageURL
  
  
  # On Avatar Remove
  #
  onAvatarRemove: (event) ->
    @props.onRemove() if _.isFunction(@props.onRemove)


  render: ->
    personInitials = initials(@props.value)

    (tag.aside {
      className:  'avatar'
      onClick:    @props.onClick
      style:
        backgroundColor:  if @props.avatarURL then "transparent" else colors.colors[colors.colorIndex(personInitials)]
        backgroundImage:  if @props.avatarURL then "url(#{@props.avatarURL})" else "none"
    },

      (tag.label null,

        (tag.input {
          onChange: @onAvatarChange
          type:     'file'
          value:    ''
        })

      ) unless @props.readOnly or @props.onClick

      (tag.i {
        className:  'fa fa-times remove'
        onClick:    @onAvatarRemove
      }) if @props.avatarURL and !@props.readOnly

      (tag.figure null, personInitials) unless @props.avatarURL
    )


# Exports
#
module.exports = Component
