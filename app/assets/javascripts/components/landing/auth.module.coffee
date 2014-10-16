# @cjsx React.DOM

# Imports
#
ModalActions  = require('actions/modal_actions')
LoginForm     = cc.require('react/modals/login-form')


# Main
#
Component = React.createClass


  onClick: ->
    ModalActions.show(<LoginForm />)


  render: ->
    <span onClick={@onClick}>Log In</span>


# Exports
#
module.exports = Component
