# @cjsx React.DOM

GlobalState = require('global_state/state')
cx          = React.addons.classSet


# Stores
#
PinboardStore     = require('stores/pinboard_store')
RoleStore         = require('stores/role_store.cursor')
UserStore         = require('stores/user_store.cursor')

ModalStack        = require('components/modal_stack')
RoleAccessRequest = require('components/roles/access_request')

InviteActions     = require('components/roles/invite_actions')

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

  propTypes:
    user_id: React.PropTypes.string.isRequired
    uuid:    React.PropTypes.string.isRequired

  getDefaultProps: ->
    cursor:
      roles: RoleStore.cursor.items

  getInitialState: ->
    loaders: Immutable.Map()


  # Helpers
  #
  isLoaded: ->
    @getPinboard() && @getViewer()

  getPinboard: ->
    @cursor.pinboard.deref(false)

  getViewer: ->
    @cursor.viewer.deref(false)

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
      'fa':           true
      'fa-lock':      @cursor.pinboard.get('access_rights') is 'private'
      'fa-eye-slash': @cursor.pinboard.get('access_rights') is 'protected'

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

  renderOwner: ->
    return <div /> if @cursor.pinboard.get('user_id') == @props.user_id

    <Human 
      type = "user"
      uuid = { @cursor.pinboard.get('user_id') } />

  renderFooter: ->
    <footer>
      { @renderOwner() }

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


  render: ->
    return null unless @isLoaded()

    <section className="pinboard cloud-card link">
      <a className="for-group" href={ @cursor.pinboard.get('url') } onClick = { @handleLinkClick } >
        { @renderHeader() }
        { @renderDescription() }
      </a>
      { @renderFooter() }
      <InviteActions ownerId = { @props.uuid } ownerType = { 'Pinboard' } />
    </section>
