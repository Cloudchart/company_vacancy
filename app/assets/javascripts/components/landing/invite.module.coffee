# @cjsx React.DOM

# Imports
#
ModalActions  = require('actions/modal_actions')
InviteForm    = cc.require('react/modals/invite-form')


# Main
#
Component = React.createClass


  onClick: ->
    ModalActions.show(<InviteForm />)


  render: ->
    <button onClick={@onClick}>{@props.value}</button>


# Exports
#
module.exports = Component
