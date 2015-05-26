# @cjsx React.DOM

GlobalState = require('global_state/state')
cx          = React.addons.classSet


# Stores
#
PinboardStore     = require('stores/pinboard_store')
RoleStore         = require('stores/role_store.cursor')
UserStore         = require('stores/user_store.cursor')

SyncButton        = require('components/form/buttons').SyncButton
ModalStack        = require('components/modal_stack')
RoleAccessRequest = require('components/roles/access_request')

# Components
#
Human = require('components/human')


# Exports
#
module.exports = React.createClass


  displayName: 'Pinboard'


  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  statics:

    queries:

      pinboard: ->
        """
          Pinboard {
            user,
            readers,
            followers,
            pins
          }
        """

  fetch: ->
    GlobalState.fetch(@getQuery('pinboard'), { id: @props.uuid }).then =>
      @setState
        loaders: @state.loaders.set('pinboard', true)

  getDefaultProps: ->
    cursor:
      roles: RoleStore.cursor.items

  getInitialState: ->
    loaders: Immutable.Map()
    sync:    Immutable.Map()


  # Helpers
  #
  isLoaded: ->
    @getPinboard() && @getViewer()

  getPinboard: ->
    @cursor.pinboard.deref(false)

  getViewer: ->
    @cursor.viewer.deref(false)

  getRole: ->
    RoleStore.rolesOnOwnerForUser(@getPinboard(), 'Pinboard', @getViewer()).first()

  isInvited: ->
    @getRole() && @getRole().get('pending_value')

  isProtected: ->
    @getPinboard().get('access_rights') == 'protected' &&
    !PinboardStore.filterUserPinboards(@getViewer().get('uuid')).contains(@getPinboard())

  openRequest: ->
    ModalStack.show(
      <RoleAccessRequest
        ownerId    = { @props.uuid }
        ownerType  = 'Pinboard' />
    )


  # Handlers
  #
  handleDeclineClick: (event) ->
    event.preventDefault()
    event.stopPropagation()

    @setState(sync: @state.sync.set('decline', true))

    RoleStore.destroy(@getRole().get('uuid')).done =>
      @setState(sync: @state.sync.set('decline', false))

  handleAcceptClick: (event) ->
    event.preventDefault()
    event.stopPropagation()

    @setState(sync: @state.sync.set('accept', true))

    RoleStore.accept(@getRole()).done =>
      @setState(sync: @state.sync.set('decline', false))

  handleLinkClick: ->
    return unless @isProtected()

    event.preventDefault()
    event.stopPropagation()
    @openRequest()


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      pinboard: PinboardStore.cursor.items.cursor(@props.uuid)
      viewer:   UserStore.me()

    @fetch() unless @isLoaded()


  # Renderers
  #
  renderAccessRightsIcon: ->
    classList = cx
      'fa':       true
      'fa-lock':  @cursor.pinboard.get('access_rights') is 'private'
      'fa-users': @cursor.pinboard.get('access_rights') is 'protected'

    <i className={ classList } />

  renderHeader: ->
    <header>
      { @cursor.pinboard.get('title') }
      { @renderAccessRightsIcon() }
    </header>

  renderDescription: ->
    return unless description = @cursor.pinboard.get('description', false)

    <section className="paragraph">
      { description }
    </section>

  renderFooter: ->
    <footer>
      <Human 
        type = "user"
        uuid = { @cursor.pinboard.get('user_id') } />

      <ul className="counters">
        <li>
          { @cursor.pinboard.get('readers_count') }
          <span className="icon">
            <i className="fa fa-male" />
          </span>
        </li>
        <li>
          { @cursor.pinboard.get('pins_count') }
          <span className="icon">
            <i className="fa fa-thumb-tack" />
          </span>
        </li>
      </ul>
    </footer>

  renderInviteActions: ->
    return null unless @isInvited()

    <div className="buttons">
      <SyncButton 
        className = "cc alert"
        iconClass = "fa-close"
        onClick   = { @handleDeclineClick }
        sync      = { @state.sync.get('decline') }
        text      = "Decline" />
      <SyncButton 
        className = "cc"
        iconClass = "fa-check"
        onClick   = { @handleAcceptClick }
        sync      = { @state.sync.get('accept') }
        text      = "Accept" />
    </div>


  render: ->
    return null unless @isLoaded()

    <section className="pinboard cloud-card link">
      <a className="for-group" href={ @cursor.pinboard.get('url') } onClick = { @handleLinkClick } >
        { @renderHeader() }
        { @renderInviteActions() }
        { @renderDescription() }
      </a>
      { @renderFooter() }
    </section>
