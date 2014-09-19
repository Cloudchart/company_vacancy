# Imports
#
tag = React.DOM

Buttons = require('components/company/buttons')
Actions = require('actions/roles')


# Main
#
Component = React.createClass


  onRevokeButtonClick: ->
    Actions.revoke(@props.key)


  render: ->
    (tag.tr {
      className: 'role'
    },
      
      (tag.td {
        className: 'name'
      },
        @props.user.full_name

        (tag.i {
          className: 'email'
          style:
            display: 'block'
        },
          @props.user.email
        )
      )
      
      
      (tag.td {
        className: 'role'
      },
        @props.role
      )
      
      (tag.td {
        className: 'actions'
      },
      
        (Buttons.SyncButton {
          title:    'Revoke'
          sync:     @props.sync == 'revoke'
          disabled: @props.sync
          onClick:  @onRevokeButtonClick
        }) unless @props.role == 'owner'
      
      )
      
    )


# Exports
#
module.exports = Component
