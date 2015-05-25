# @cjsx React.DOM

# Imports
#
GlobalState      = require('global_state/state')

RoleStore        = require("stores/role_store.cursor")
UserStore        = require("stores/user_store.cursor")
TokenStore       = require("stores/token_store.cursor")
PinboardStore    = require('stores/pinboard_store')

RoleItem         = require("components/roles/item")
StandardButton   = require('components/form/buttons').StandardButton


# Main
#
Component = React.createClass

  displayName: 'RolesUserList'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      pinboard: ->
        """
          Pinboard {
            roles {
              user
            },
            tokens {
              target
            }
          }
        """

  propTypes:
    ownerId:       React.PropTypes.string.isRequired
    ownerType:     React.PropTypes.string.isRequired
    onInviteClick: React.PropTypes.func.isRequired
    roleValues:    React.PropTypes.array.isRequired

  getDefaultProps: ->
    cursor:
      roles:  RoleStore.cursor.items
      tokens: TokenStore.cursor.items
      users:  UserStore.cursor.items

  getInitialState: ->
    isLoaded: false

  fetch: ->
    GlobalState.fetch(@getQuery('pinboard'), { id: @props.ownerId })


  # Helpers
  #
  getRoles: ->
    RoleStore.rolesOn(@props.ownerId, @props.ownerType)

  getTokens: ->
    TokenStore.filterAccessRequestsByOwner(@props.ownerId, @props.ownerType)

  getPinboard: ->
    PinboardStore.cursor.items.get(@props.ownerId)

  getUser: ->
    UserStore.cursor.items.get(@getPinboard().get('user_id'))

  isLoaded: ->
    @state.isLoaded


  # Lifecyle methods
  #
  componentWillMount: ->
    @fetch().then => @setState isLoaded: true


  # Renderers
  #
  renderRoles: ->
    owner = @getUser()

    Immutable.Seq([
      <RoleItem
        user        = { owner }
        key         = 'owner'
        roleValues  = { @props.roleValues }
        owner       = { @getPinboard() }
        ownerType   = { @props.ownerType } />
    ]).concat(
      @getRoles()
        .sortBy (role) -> role.get('created_at')
        .map (role, index) => 
          user = UserStore.cursor.items.get(role.get('user_id'))

          <RoleItem
            user       = { user }
            role       = { role }
            key        = { role.get('uuid') }
            roleValues = { @props.roleValues }
            owner      = { @getPinboard() }
            ownerType  = { @props.ownerType } />
        .valueSeq()
    ).concat(
      @getTokens()
        .sortBy (token) -> token.get('created_at')
        .map (token, index) => 
          user = UserStore.cursor.items.get(token.get('target_id'))

          <RoleItem
            user       = { user }
            token      = { token }
            key        = { token.get('uuid') }
            roleValues = { @props.roleValues }
            owner      = { @getPinboard() }
            ownerType  = { @props.ownerType } />
        .valueSeq()
    )
    .toArray()

  render: ->
    return null unless @isLoaded()

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
