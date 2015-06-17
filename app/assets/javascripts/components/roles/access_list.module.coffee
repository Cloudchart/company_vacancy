# @cjsx React.DOM

# Imports
#
GlobalState      = require('global_state/state')

RoleStore        = require("stores/role_store.cursor")
UserStore        = require("stores/user_store.cursor")
TokenStore       = require("stores/token_store.cursor")

getOwnerStore    = require('utils/owners').getStore

AccessItem       = require("components/roles/access_item")
StandardButton   = require('components/form/buttons').StandardButton


# Main
#
Component = React.createClass

  displayName: 'RolesAccessList'

  propTypes:
    ownerId:       React.PropTypes.string.isRequired
    ownerType:     React.PropTypes.string.isRequired
    onInviteClick: React.PropTypes.func.isRequired
    roleValues:    React.PropTypes.array.isRequired

  mixins: [GlobalState.mixin]

  getDefaultProps: ->
    cursor:
      roles:  RoleStore.cursor.items
      tokens: TokenStore.cursor.items
      users:  UserStore.cursor.items


  # Helpers
  #
  getRoles: ->
    RoleStore.rolesOn(@props.ownerId, @props.ownerType)

  getTokens: ->
    TokenStore.filterAccessRequestsByOwner(@props.ownerId, @props.ownerType)

  getOwner: ->
    getOwnerStore(@props.ownerType).cursor.items.get(@props.ownerId)

  getUserOwner: ->
    UserStore.cursor.items.get(@getOwner().get('user_id'))


  # Renderers
  #
  renderRoles: ->
    owner = @getUserOwner()

    Immutable.Seq([
      <AccessItem
        user        = { owner }
        key         = 'owner'
        isUserOwner = { true }
        roleValues  = { @props.roleValues }
        owner       = { @getOwner() }
        ownerType   = { @props.ownerType } />
    ]).concat(
      @getRoles()
        .sortBy (role) -> role.get('created_at')
        .filter (role) -> role.get('value') != 'owner'
        .map (role, index) =>
          user = UserStore.cursor.items.get(role.get('user_id'))

          <AccessItem
            user       = { user }
            role       = { role }
            key        = { role.get('uuid') }
            roleValues = { @props.roleValues }
            owner      = { @getOwner() }
            ownerType  = { @props.ownerType } />
        .valueSeq()
    ).concat(
      @getTokens()
        .sortBy (token) -> token.get('created_at')
        .map (token, index) => 
          user = UserStore.cursor.items.get(token.get('target_id'))

          <AccessItem
            user       = { user }
            token      = { token }
            key        = { token.get('uuid') }
            roleValues = { @props.roleValues }
            owner      = { @getOwner() }
            ownerType  = { @props.ownerType } />
        .valueSeq()
    )
    .toArray()

  render: ->
    <section className="user-list">
      <ul>
        { @renderRoles() }
      </ul>
      <StandardButton
        className = "cc cc-wide"
        text      = "Invite"
        onClick   = { @props.onInviteClick } />
    </section>


# Exports
#
module.exports = Component
