# Imports
#
tag = cc.require('react/dom')


# Main Component
#
Component = React.createClass


  onClick: (event) ->
    event = new CustomEvent 'modal:close'
    window.dispatchEvent(event)


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
cc.module('react/modals/splash').exports = Component
