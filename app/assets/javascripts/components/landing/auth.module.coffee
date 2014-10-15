# Imports
#
tag = React.DOM


ModalActions  = require('actions/modal_actions')
LoginForm     = cc.require('react/modals/login-form')


# Main
#
Component = React.createClass


  onClick: ->
    ModalActions.show(LoginForm(null))


  render: ->
    (tag.span {
      onClick: @onClick
    },
      "Log In"
    )


# Exports
#
module.exports = Component
