# @cjsx React.DOM

# Imports
#
GlobalState      = require('global_state/state')

PinboardStore    = require('stores/pinboard_store')
RoleStore        = require("stores/role_store.cursor")
UserStore        = require("stores/user_store.cursor")

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

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:
    queries:
      pinboard: ->
        """
          Pinboard {
            roles {
              user
            },
            edges {
              role_ids
            }
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('pinboard'), { id: @props.ownerId }).then (json) =>
      @setState
        ready: true


  # Specification
  #
  getInitialState: ->
    ready: false

  getDefaultProps: ->
    cursor:
      roles: RoleStore.cursor.items
      users: UserStore.cursor.items


  # Lifecycle
  #
  componentDidMount: ->
    @fetch()


  # Helpers
  #
  getPinboard: ->
    PinboardStore.get(@props.ownerId)

  getRoles: ->
    @getPinboard().get('role_ids').map (id) -> RoleStore.get(id)

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
    )
    .toArray()

  render: ->
    return null unless @state.ready

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
