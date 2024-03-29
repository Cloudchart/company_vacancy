# Imports
#
tag = React.DOM

ModalStack = require('components/modal_stack')


# Main Component
#
Component = React.createClass


  onClick: (event) ->
    # ModalStack.hide()
    location.href = '/'


  render: ->
    (tag.div {
      className: 'splash'
    },
      (tag.header {}, @props.header) if @props.header
      
      (tag.figure { className: 'cloud-chart' })
      
      (tag.p {
        dangerouslySetInnerHTML:
          __html: @props.note
      }) if @props.note

      (tag.button {
        onClick:  @onClick
      }, 'Okay')
    )


# Exports
#
module.exports = Component
