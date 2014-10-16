# Imports
#
tag = React.DOM


RolesStore    = require('stores/roles')
TokenStore    = require('stores/token')
UsersStore    = require('stores/users')

RoleItem      = require('components/company/role_item')
TokenItem     = require('components/company/token_item')


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
        user:            UsersStore.get(role.user_id)
        sync:            RolesStore.getSync(role.uuid)
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
