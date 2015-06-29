# @cjsx React.DOM

GlobalState = require('global_state/state')

# Stores
#
PinboardStore = require('stores/pinboard_store')
UserStore = require('stores/user_store.cursor')
PinStore = require('stores/pin_store')
RoleStore = require('stores/role_store.cursor')
FavoriteStore = require('stores/favorite_store.cursor')

# Components
#
PinboardSettings = require('components/pinboards/settings')
PinboardAccess = require('components/pinboards/access_rights')
PinboardPins = require('components/pinboards/pins/pinboard')
PinboardTabs = require('components/pinboards/tabs')
ModalStack = require('components/modal_stack')
InviteActions = require('components/roles/invite_actions')
RelatedUsers = require('components/pinboards/related_users')
FollowButton = require('components/pinboards/follow_button')
ShareButtons = require('components/shared/share_buttons')
Buttons = require('components/form/buttons')
SyncButton = Buttons.SyncButton
AuthButton = Buttons.AuthButton

SyncApi = require('sync/pinboard_sync_api')

pluralize = require('utils/pluralize')


# Exports
#
module.exports = React.createClass

  displayName: 'PinboardApp'

  propTypes:
    uuid: React.PropTypes.string.isRequired

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      pinboard: ->
        """
          Pinboard {
            #{FollowButton.getQuery('pinboard')},
            user,
            readers,
            writers,
            followers,
            pins,
            edges {
              pinboard_url,
              facebook_share_url,
              twitter_share_url
            }
          }
        """

      viewer: ->
        """
          Viewer {
            roles,
            favorites
          }
        """

  getDefaultProps: ->
    cursor:
      pinboards: PinboardStore.cursor.items
      pins:      PinStore.cursor.items
      favorites: FavoriteStore.cursor.items
      roles:     RoleStore.cursor.items
      viewer:    UserStore.me()

  getInitialState: ->
    uuid:       @props.uuid
    currentTab: null
    isSyncing:  false

  fetch: ->
    Promise.all([
      GlobalState.fetch(@getQuery('pinboard'), { id: @props.uuid }),
      @fetchViewer()
    ])

  fetchViewer: (options={}) ->
    GlobalState.fetch(@getQuery('viewer'), options)


  # Helpers
  #
  isLoaded: ->
    @getPinboard()

  getPinboard: ->
    PinboardStore.cursor.items.cursor(@props.uuid).deref(false)

  getOwner: ->
    UserStore.cursor.items.get(@getPinboard().get('user_id'))

  getViewerId: ->
    @props.cursor.viewer.get('uuid')

  getFavorite: ->
    FavoriteStore.findByPinboardForUser(@props.uuid, @getViewerId())

  isViewerOwner: ->
    @getOwner().get('uuid') == @getViewerId()

  getViewerRole: ->
    RoleStore.rolesOnOwnerForUser(@props.uuid, 'Pinboard', @props.cursor.viewer).first()

  isViewerEditor: ->
    !!(role = @getViewerRole()) && role.get('value') == 'editor'

  canViewerEdit: ->
    @isViewerOwner() || @isViewerEditor()

  getEditors: ->
    result = @props.cursor.roles
      .filter (role) => role.get('owner_id') == @props.uuid && role.get('value') == 'editor'
      .map (role) -> UserStore.get(role.get('user_id'))
      .valueSeq()


  # Handlers
  #
  handleTabChange: (tab) ->
    @setState currentTab: tab


  # Lifecycle methods
  #
  componentWillMount: ->
    @fetch() unless @isLoaded()

  handleFollowClick: ->
    # TODO
    # make the united Follow Sync API

    @setState(isSyncing: true)

    if favorite = @getFavorite()
      SyncApi.unfollow(@props.uuid).then =>
        favoriteId = favorite.get('uuid')
        FavoriteStore.remove(favoriteId)
        @setState(isSyncing: false)
    else
      SyncApi.follow(@props.uuid).then =>
        @fetchViewer(force: true).then => @setState(isSyncing: false)

  handleOthersLinkClick: (event) ->
    event.preventDefault()

    ModalStack.show(
      <RelatedUsers
        pinboard = { @getPinboard().toJS() }
        owner = { @getOwner().toJS() }
        users = { @getEditors().toJS() }
      />
    )


  # Renderers
  #
  renderOthersLink: ->
    users = @getEditors()
    users_size = users.size
    return null unless users_size
    return null if users_size == 0

    link = if users_size == 1
      user = users.first()
      <a key=2 href={ user.get('user_url') }>{ user.get('full_name') }</a>
    else
      <a key=2 href="" onClick={ @handleOthersLinkClick }>{ "#{users_size} others" }</a>

    [
      <span key=1> and </span>,
      { link }
    ]


  renderFollowButton: ->
    return null if @isViewerOwner() || @isViewerEditor()

    text = if @getFavorite() then 'Unfollow' else 'Follow'

    <AuthButton>
      <SyncButton
        className         = "cc"
        onClick           = { @handleFollowClick }
        text              = { text }
        sync              = { @state.isSyncing }
      />
    </AuthButton>


  renderHeader: ->
    pinboard = @getPinboard()

    <header>
      <h1>
        { @getPinboard().get('title') }
        <span> by </span>
        <a href={ @getOwner().get('user_url') }>{ @getOwner().get('full_name') }</a>
        { @renderOthersLink() }
      </h1>

      { @renderDescription() }

      <ul className="counters">
        <li>
          { pluralize(pinboard.get('readers_count'), "follower", "followers") }
        </li>
        <li>
          { pluralize(pinboard.get('pins_count') || 0, "pin", "pins") }
        </li>
      </ul>

      <div className="buttons">
        <FollowButton pinboard={ @props.uuid } canUnfollow={ true } />
        <ShareButtons object = pinboard.toJS() />
      </div>

    </header>

  renderContent: ->
    switch @state.currentTab
      when 'insights'
        <PinboardPins pinboard_id = { @props.uuid } />
      when 'settings'
        <PinboardSettings uuid = { @props.uuid } />
      when 'users'
        <PinboardAccess uuid = { @props.uuid } />
      else
        null

  renderDescription: ->
    description = @getPinboard().get('description')
    return null unless description

    <div className="description">{ description }</div>


  render: ->
    return null unless @isLoaded()

    <section className="user-pinboards">
      <section className="tab-header">
        <div className="cloud-columns cloud-columns-flex">
          { @renderHeader() }
          <InviteActions ownerId = { @props.uuid } ownerType = 'Pinboard' />
          <PinboardTabs
            insightsNumber = { @getPinboard().get('pins_count') }
            canEdit        = { @canViewerEdit() }
            onChange       = { @handleTabChange } />
        </div>
      </section>
      { @renderContent() }
    </section>
