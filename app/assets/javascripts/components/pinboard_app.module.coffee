# @cjsx React.DOM

GlobalState     = require('global_state/state')

# Stores
#
PinboardStore   = require('stores/pinboard_store')
UserStore       = require('stores/user_store.cursor')
PinStore        = require('stores/pin_store')
RoleStore       = require('stores/role_store.cursor')
FavoriteStore   = require('stores/favorite_store.cursor')


# Components
#
PinboardSettings = require('components/pinboards/settings')
PinboardAccess   = require('components/pinboards/access_rights')
PinboardPins     = require('components/pinboards/pins/pinboard')
PinboardTabs     = require('components/pinboards/tabs')
SyncButton       = require('components/form/buttons').SyncButton

SyncApi          = require('sync/pinboard_sync_api')



# Exports
#
module.exports = React.createClass

  displayName: 'PinboardApp'

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

      viewer: ->
        """
          Viewer {
            roles,
            favorites
          }
        """

  propTypes:
    uuid: React.PropTypes.string.isRequired

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
    RoleStore.rolesOnOwnerForUser(@getPinboard(), 'Pinboard', @props.cursor.viewer).first()

  isViewerEditor: ->
    !!(role = @getViewerRole()) && role.get('value') == 'editor'

  canViewerEdit: ->
    @isViewerOwner() || @isViewerEditor()


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


  # Renderers
  #
  renderFollowButton: ->
    return null if @isViewerOwner() || @isViewerEditor()

    text = if @getFavorite() then 'Unfollow' else 'Follow'

    <SyncButton
      className         = "cc"
      onClick           = { @handleFollowClick }
      text              = { text }
      sync              = { @state.isSyncing } />

  renderHeader: ->
    <header>
      <h1>
        { @getPinboard().get('title') } — <a href={ @getOwner().get('user_url') }>{ @getOwner().get('full_name') }</a>
      </h1>
      <ul className="counters">
        <li>
          { @getPinboard().get('readers_count') }
          <span className="text">followers</span>
        </li>
        <li>
          { @getPinboard().get('pins_count') }
          <span className="text">pins</span>
        </li>
      </ul>
      { @renderFollowButton() }
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


  render: ->
    return null unless @isLoaded()

    <section className="user-pinboards">
      <section className="tab-header">
        <div className="cloud-columns cloud-columns-flex">
          { @renderHeader() }
          <PinboardTabs
            insightsNumber = { @getPinboard().get('pins_count') }
            canEdit        = { @canViewerEdit() }
            onChange       = { @handleTabChange } />
        </div>
      </section>
      { @renderContent() }
    </section>
