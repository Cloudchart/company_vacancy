# @cjsx React.DOM

# Imports
#
GlobalState      = require('global_state/state')

RoleStore        = require("stores/role_store.cursor")
UserStore        = require("stores/user_store.cursor")
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
      roles: RoleStore.cursor.items
      users: UserStore.cursor.items

  getInitialState: ->
    isLoaded: false

  fetch: ->
    GlobalState.fetch(@getQuery('pinboard'), { id: @props.ownerId })


  # Helpers
  #
  getRoles: ->
    RoleStore.rolesOn(@props.ownerId, @props.ownerType)

  getPinboard: ->
    PinboardStore.cursor.items.get(@props.ownerId)

  getOwner: ->
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
    owner = @getOwner()

    Immutable.Seq([
      <RoleItem
        user       = { owner }
        isOwner    = { true }
        key        = 'owner'
        roleValues = { @props.roleValues }
        ownerType  = { @props.ownerType } />
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
