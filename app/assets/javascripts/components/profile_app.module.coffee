# @cjsx React.DOM

GlobalState        = require('global_state/state')

ProfileInfo        = require('components/profile/info')
PinsComponent      = require('components/pinboards/pins')
CompaniesList      = require('components/company/list')
UserFeed           = require('components/user/feed')
Settings           = require('components/profile/settings')

UserStore          = require('stores/user_store.cursor')
PinStore           = require('stores/pin_store')
CompanyStore       = require('stores/company_store.cursor')
FavoriteStore      = require('stores/favorite_store.cursor')

Button             = require('components/form/buttons').SyncButton

SyncApi            = require('sync/user_sync_api')

EmptyTabTexts =
  activityOwn:    "Follow people and companies"
  activityOther:  "This person doesn't follow any people and companies yet"
  insightsOwn:    "Collect successful founders' insights and put them to action"
  insightsOther:  "This person hasn't added any insights yet"
  companiesOwn:   ->
    <span>
      Want to see your company on CloudChart? <a href="mailto:team@cloudchart.co">Let us know</a>
    </span>
  companiesOther: ->  
    <span>
      Does this person have a company you want to see on CloudChart? <a href="mailto:team@cloudchart.co">Let us know</a>
    </span>

cx = React.addons.classSet

module.exports = React.createClass

  displayName: 'ProfileApp'

  # Component specifications
  #
  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:
      viewer: ->
        """
          Viewer {
            favorites
          }
        """

      user: ->
        """
          User {
            followed_activities,
            #{ProfileInfo.getQuery('user')},
            #{PinsComponent.getQuery('pins')},
            #{CompaniesList.getQuery('companies')}
          }
        """ 

  propTypes:
    uuid:   React.PropTypes.string.isRequired

  getDefaultProps: ->
    cursor: FavoriteStore.cursor.items

  getInitialState: ->
    fetchDone:   false
    currentTab:  location.hash.substr(1) || null
    isSyncing:   false
    visibleTabs: Immutable.Seq()

  fetchViewer: (options={}) ->
    GlobalState.fetch(@getQuery('viewer'), options)

  fetchUser: ->
    GlobalState.fetch(@getQuery('user'), id: @props.uuid)

  fetch: ->
    Promise.all([@fetchUser(), @fetchViewer()]).then =>
      @setState
        fetchDone:   true
        currentTab:  @getInitialTab()
        visibleTabs: @getVisibleTabs()

  getStateFromStores: ->
    favorite: FavoriteStore.findByUser(@props.uuid)

  onGlobalStateChange: ->
    @setState @getStateFromStores()


  # Helpers
  #
  isLoaded: ->
    @state.fetchDone

  getMenuOptionClassName: (option) ->
    cx(active: @state.currentTab == option)

  getFavorite: ->
    @state.favorite

  getVisibleTabs: ->
    Immutable.OrderedMap(
      activity:  true
      insights:  true
      companies: true
      settings:  @cursor.user.get('is_editable')
    ).filter (visible) -> visible
    .keySeq()

  getInitialTab: ->
    visibleTabs = @getVisibleTabs()

    if !@state.currentTab || !visibleTabs.contains(@state.currentTab)
      visibleTabs.first()
    else
      @state.currentTab

  isViewerProfile: ->
    @props.uuid == @cursor.viewer.get('uuid')


  # Handlers
  #
  handleHashChange: ->
    currentTab = location.hash.substr(1)
    if @state.visibleTabs.contains(currentTab)
      @setState currentTab: currentTab

  handleFollowClick: ->
    @setState(isSyncing: true)

    if favorite = @getFavorite()
      SyncApi.unfollow(@props.uuid).then =>
        FavoriteStore.cursor.items.remove(favorite.get('uuid'))
        @setState(isSyncing: false)
    else
      SyncApi.follow(@props.uuid).then => 
        # TODO rewrite with grabbing only needed favorite
        @fetchViewer(force: true).then => @setState(isSyncing: false)


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor = 
      companies:  CompanyStore.cursor.items
      pins:       PinStore.cursor.items
      viewer:     UserStore.me()
      user:       UserStore.cursor.items.cursor(@props.uuid)

    @fetch() unless @isLoaded()

    window.addEventListener 'hashchange', @handleHashChange

  componentWillUnmount: ->
    window.removeEventListener 'hashchange', @handleHashChange


  # Renderers
  #
  renderTabs: ->
    @state.visibleTabs.map (tabName) =>
      <li key = { tabName } className = { @getMenuOptionClassName(tabName) } >
        <a href = { location.pathname + "#" + tabName } className="for-group">
          { tabName }
        </a>
      </li>
    .toArray()

  renderMenu: ->
    <nav className="tabs">
      <ul>
        { @renderTabs() }
      </ul>
    </nav>

  renderFollowButton: ->
    return null if @isViewerProfile()

    text = if @getFavorite() then 'Unfollow' else 'Follow'

    <Button 
      className         = "cc follow-button"
      onClick           = { @handleFollowClick }
      text              = { text }
      sync              = { @state.isSyncing }
      showSyncAnimation = { false } />

  renderEmptyTabText: (key) ->
    emptyTextKey = key + (if @isViewerProfile() then "Own" else "Other")
    renderedText = if _.isFunction(text = EmptyTabTexts[emptyTextKey]) then text() else text

    <p className="empty">
      { renderedText }
    </p>

  renderActivity: ->
    unless UserFeed.isEmpty()
      <UserFeed />
    else
      @renderEmptyTabText("activity")

  renderCompanies: ->
    unless CompaniesList.isEmpty(@props.uuid)
      <CompaniesList user_id = { @props.uuid } />
    else
      @renderEmptyTabText("companies")

  renderInsights: ->
    unless PinsComponent.isEmpty(@props.uuid)
      <PinsComponent user_id = { @props.uuid } showOnlyInsights = { !@isViewerProfile() } />
    else
      @renderEmptyTabText("insights")

  renderContent: ->
    switch @state.currentTab
      when 'insights'
        @renderInsights()
      when 'companies'
        @renderCompanies()
      when 'activity'
        @renderActivity()
      when 'settings'
        <Settings uuid = { @props.uuid } 
          withEmails = { @isViewerProfile() } />


  render: ->
    return null unless @isLoaded()

    <section className="user-profile">
      <header>
        <div className="cloud-columns cloud-columns-flex">
          <ProfileInfo uuid = { @props.uuid } />
          { @renderMenu() }
          { @renderFollowButton() }
        </div>
      </header>
      { @renderContent() }
    </section>
