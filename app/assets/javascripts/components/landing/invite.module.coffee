# @cjsx React.DOM

# Imports
#
ModalActions  = require('components/modal_stack')
InviteForm    = require('react_components/modals/invite_form')


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
