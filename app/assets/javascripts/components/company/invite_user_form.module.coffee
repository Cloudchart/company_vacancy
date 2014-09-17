# Imports
#
tag = React.DOM

Buttons = require('components/company/buttons')


# Main
#
Component = React.createClass


  onSubmit: (event) ->
    event.preventDefault()


  render: ->
    (tag.form {
      className:  'invite-user'
      onSubmit:   @onSubmit
    },
    
      # Footer / Button
      #
      (tag.footer null,
        (Buttons.SendInviteButton {
          onClick: @onSendInviteButtonClick
        })
      )
    
    )


# Exports
#
module.exports = Component
