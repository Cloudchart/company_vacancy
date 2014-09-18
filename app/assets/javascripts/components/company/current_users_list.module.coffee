# Imports
#
tag = React.DOM


RolesStore    = require('stores/roles')
RolesActions  = require('actions/roles')
TokenStore    = require('stores/token_store')
TokenItem     = require('components/company/token_item')
Buttons       = require('components/company/buttons')


# Main
#
Component = React.createClass


  onRevokeRoleButtonClick: (key) ->
    RolesActions.revoke(key, key)


  currentUsers: ->
    _.map @props.users, (user) =>
      
      role = _.find @props.roles, (role) -> role.user_id == user.uuid
      
      (tag.tr {
        key: user.uuid
      },
      
        (tag.td {
          className: 'name'
        },
          user.full_name
          (tag.br null)
          user.email
        )
        
        (tag.td {
          className: 'role'
        },
          role.value if role
        )
        
        (tag.td {
          className: 'actions'
        },
          (Buttons.RevokeRoleButton {
            sync:       RolesStore.is_in_sync(role.uuid)
            disabled:   RolesStore.is_in_sync(role.uuid)
            onClick:    @onRevokeRoleButtonClick.bind(@, role.uuid)
          }) unless role.value == 'owner'
        )
      
      )
      
  
  currentTokens: ->
    _.map @props.tokens, (token, key) ->
      (TokenItem {
        key:    key
        email:  token.data.email
        role:   token.data.role
        sync:   TokenStore.getSync(key)
        company:
          key:  token.owner_id
      })
  
  
  render: ->
    (tag.table {
      className: 'current-users-list'
    },
      (tag.tbody {
      },
        @currentUsers()
        @currentTokens()
      )
    )


# Exports
#
module.exports = Component
