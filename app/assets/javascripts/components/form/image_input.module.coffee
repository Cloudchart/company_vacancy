# Imports
#
tag = React.DOM


# Main
#
Component = React.createClass

  
  onChange: (event) ->
    file  = event.target.files[0] ; return unless file
    image = new Image

    image.addEventListener 'load', =>
      @props.onChange(file) if _.isFunction(@props.onChange)
      URL.revokeObjectURL(image.src)
    
    image.addEventListener 'error', =>
      @props.onError() if _.isFunction(@props.onError)
      URL.revokeObjectURL(image.src)

    image.src = URL.createObjectURL(file)


  render: ->
    (tag.div {
      className: 'image-input'
    },

      (tag.label {
      },
        (tag.input {
          type:       'file'
          onChange:   @onChange
          value:      ''
        }) unless @props.readOnly

        @props.placeholder unless @props.src
      
        @transferPropsTo((tag.img {})) if @props.src

      )
      
      # (tag.i {
      #   className:  'fa fa-times remove'
      #   onClick:    @props.onDelete
      # }) if @props.src unless @props.readOnly

      # (tag.button {
      #   className:  'delete'
      #   onClick:    @props.onDelete
      #   type:       'button'
      # },
      #   (tag.i { className: 'fa fa-times' })
      # ) if @props.src unless @props.readOnly
    )


# Exports
#
module.exports = Component
