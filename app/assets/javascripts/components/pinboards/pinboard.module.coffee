# @cjsx React.DOM

GlobalState = require('global_state/state')
cx          = React.addons.classSet


# Stores
#
PinboardStore     = require('stores/pinboard_store')
RoleStore         = require('stores/role_store.cursor')
UserStore         = require('stores/user_store.cursor')
FavoriteStore     = require('stores/favorite_store.cursor')

SyncApi           = require('sync/pinboard_sync_api')


ModalStack        = require('components/modal_stack')
ModalError        = require('components/error/modal')
RoleAccessRequest = require('components/roles/access_request')
SyncButton        = require('components/form/buttons').SyncButton
AuthButton        = require('components/form/buttons').AuthButton


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

      favorites: ->
        """
          Viewer {
            favorites
          }
        """

  fetch: ->
    GlobalState.fetch(@getQuery('pinboard'), { id: @props.uuid }).then (pinboard) =>
      @setState
        loaders: @state.loaders.set('pinboard', true)

  fetchFavorites: (options={}) ->
    GlobalState.fetch(@getQuery('favorites'), options)

  propTypes:
    user_id: React.PropTypes.string
    uuid:    React.PropTypes.string.isRequired

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

  getOwner: ->
    UserStore.cursor.items.get(@getPinboard().get('user_id'))

  getFavorite: ->
    FavoriteStore.findByPinboardForUser(@props.uuid, @cursor.viewer.get('uuid'))

  isViewerOwner: ->
    @getOwner().get('uuid') == @getViewer().get('uuid')

  viewerHasRole: ->
    RoleStore.rolesOnOwnerForUser(@props.uuid, 'Pinboard', @cursor.viewer).first()

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

  handleFollowClick: (event) ->
    event.preventDefault()
    event.stopPropagation()

    @setState(sync: @state.sync.set('follow', true))

    SyncApi.follow(@cursor.pinboard.get('uuid'))
      .then @handleFollowDone
      .catch @handleFollowFail

  handleFollowDone: ->
    # TODO rewrite with grabbing only needed favorite
    @fetchFavorites(force: true).then => 
      @setState(sync: @state.sync.set('follow', false))

  handleFollowFail: ->
    @setState(sync: @state.sync.set('follow', false))

    ModalStack.show(<ModalError />)


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      pinboard: PinboardStore.cursor.items.cursor(@props.uuid)
      viewer:   UserStore.me()

    @fetch()


  # Renderers
  #
  renderFollowButton: ->
    return null unless !@getFavorite() && !@viewerHasRole() && !@isViewerOwner()

    <AuthButton>
      <SyncButton
        className = "cc follow"
        onClick   = { @handleFollowClick }
        sync      = { @state.sync.get('follow') }
        text      = "Follow"
      />
    </AuthButton>

  renderFollowedLabel: ->
    return null unless @getFavorite() && !@viewerHasRole() && !@isViewerOwner()

    <span className="label">Following</span>

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
      { @renderFollowButton() }
      { @renderFollowedLabel() }
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

      <ul className="stats">
        <li>
          { @cursor.pinboard.get('readers_count') + ' Followers' }
        </li>
        <li>
          { @cursor.pinboard.get('pins_count') + ' Insights' }
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
