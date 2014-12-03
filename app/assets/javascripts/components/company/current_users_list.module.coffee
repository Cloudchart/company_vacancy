# Imports
#
tag = React.DOM

UserStore = require('stores/user_store')
RoleStore = require('stores/role_store')
TokenStore = require('stores/token_store')

RoleItem = require('components/company/role_item')
TokenItem = require('components/company/token_item')


# Main
#
Component = React.createClass

  getDefaultProps: ->
    invitable_roles: []

  onRevokeRoleButtonClick: (key) ->
    RolesActions.revoke(key, key)


  currentUsers: ->
    _.map @props.roles, (role) =>
      (RoleItem {
        key:             role.uuid
        role:            role.value
        user:            UserStore.get(role.user_id)
        sync:            RoleStore.getSync(role.uuid)
        invitable_roles: @props.invitable_roles
      })
  
  currentTokens: ->
    _.map @props.tokens, (token) ->
      (TokenItem {
        key:    token.uuid
        email:  token.data.email
        role:   token.data.role
        sync:   TokenStore.getSync(token.uuid)
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
