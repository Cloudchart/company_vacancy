# Imports
#
tag = React.DOM


AccessRightsStore   = require('stores/company_access_rights')
AccessRightsActions = require('actions/access_rights')
TokenStore          = require('stores/token_store')
TokenItem           = require('components/company/token_item')
Buttons             = require('components/company/buttons')


# Main
#
Component = React.createClass


  onRevokeRoleButtonClick: (key) ->
    AccessRightsActions.revoke(key, key)


  currentUsers: ->
    _.map @props.users, (user) =>
      
      ar = _.find @props.access_rights, (ar) -> ar.user_id == user.uuid
      
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
          ar.role if ar
        )
        
        (tag.td {
          className: 'actions'
        },
          (Buttons.RevokeRoleButton {
            sync:       AccessRightsStore.is_in_sync(ar.uuid)
            disabled:   AccessRightsStore.is_in_sync(ar.uuid)
            onClick:    @onRevokeRoleButtonClick.bind(@, ar.uuid)
          })
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
