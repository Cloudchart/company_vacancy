# Imports
#
tag = React.DOM


ModalActions  = require('actions/modal_actions')
InviteForm    = cc.require('react/modals/invite-form')


# Main
#
Component = React.createClass


  onClick: ->
    ModalActions.show(InviteForm(null))


  render: ->
    (tag.button {
      onClick: @onClick
    },
      @props.value
    )


# Exports
#
module.exports = Component
