# @cjsx React.DOM

GlobalState    = require('global_state/state')

RoleStore      = require('stores/role_store.cursor')
UserStore      = require('stores/user_store.cursor')

ModalStack     = require('components/modal_stack')
ModalError     = require('components/error/modal')

getOwnerName   = require('utils/owners').getName
getOwnerStore  = require('utils/owners').getStore

SyncButton     = require('components/form/buttons').SyncButton


InviteActions = React.createClass

  displayName: 'InviteActions'
  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  propTypes:
    ownerId:    React.PropTypes.string.isRequired
    ownerType:  React.PropTypes.string.isRequired

  statics:
    queries:
      owner: (type) ->
        """
          #{type} {
            roles,
            edges {
              is_invited
            }
          }
        """


  # Component specifications
  #
  getDefaultProps: ->
    cursor:
      roles:   RoleStore.cursor.items
      viewer:  UserStore.me()

  getInitialState: ->
    sync: Immutable.Map()
    isInvited: false


  # Fetchers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('owner', @props.ownerType), id: @props.ownerId).then (json) =>
      isInvited = if json.companies
        json.companies[0].is_invited
      else
        json.is_invited

      @setState isInvited: isInvited


  # Lifecycle methods
  #
  componentWillMount: ->
    @fetch().then => @setState isLoaded: true


  # Helpers
  #
  getOwner: ->
    getOwnerStore(@props.ownerType).cursor.items.get(@props.ownerId)

  # TODO: get role from query
  getRole: ->
    RoleStore.rolesOnOwnerForUser(@props.ownerId, @props.ownerType, @props.cursor.viewer).first()


  # Handlers
  #
  handleDeclineClick: (event) ->
    event.preventDefault()
    event.stopPropagation()

    @setState(sync: @state.sync.set('decline', true))

    RoleStore.destroy(@getRole().get('uuid'))
      .then => @handleInviteDone('decline')
      .catch => @handleFail('decline')

  handleAcceptClick: (event) ->
    event.preventDefault()
    event.stopPropagation()

    @setState(sync: @state.sync.set('accept', true))

    RoleStore.accept(@getRole())
      .then => @handleInviteDone('accept')
      .catch => @handleFail('accept')

  handleInviteDone: (syncKey) ->
    # needed for pinboards and companies cards rerender
    GlobalState.fetchEdges(@props.ownerType, @props.ownerId, 'is_invited')

    @setState(sync: @state.sync.set(syncKey, false), isInvited: false)

  handleFail: (syncKey) ->
    @setState(sync: @state.sync.set(syncKey, false))

    ModalStack.show(<ModalError />)


  # Main render
  #
  render: ->
    return null unless @state.isInvited

    <section className="invite-actions">
      <p>
        { "#{@props.cursor.viewer.get('first_name')}, you've been invited to this #{getOwnerName(@props.ownerType)}" }
      </p>

      <div className="buttons">
        <SyncButton
          className = "cc"
          onClick   = { @handleAcceptClick }
          sync      = { @state.sync.get('accept') }
          text      = "Accept" 
        />

        <SyncButton
          className = "cc alert"
          onClick   = { @handleDeclineClick }
          sync      = { @state.sync.get('decline') }
          text      = "Decline"
        />
      </div>
    </section>

module.exports = InviteActions
