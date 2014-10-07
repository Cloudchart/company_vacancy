# Imports
#
tag = React.DOM

Buttons = require('components/company/buttons')
Actions = require('actions/roles')
roleMaps = require('utils/role_maps')

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

        (tag.span {
          className: 'email'
          style:
            display: 'block'
        },
          @props.user.email
        )
      )
      
      
      (tag.td {
        className: 'user-role'
      },
        roleMaps.RoleNameMap[@props.role]
      )
      
      (tag.td {
        className: 'actions'
      },
      
        (Buttons.SyncButton {
          className: 'cc-table revoke'
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
