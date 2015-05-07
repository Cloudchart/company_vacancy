# @cjsx React.DOM

GlobalState        = require('global_state/state')

ProfileInfo        = require('components/profile/info')
UserPins           = require('components/pinboards/pins/user')
UserCompanies      = require('components/company/lists/user')
UserFeed           = require('components/user/feed')
Settings           = require('components/profile/settings')

UserStore          = require('stores/user_store.cursor')
PinStore           = require('stores/pin_store')
CompanyStore       = require('stores/company_store.cursor')


EmptyTabTexts =
  feedOwn:        "Follow people and companies you're interested in to learn from them"
  feedOther:      "This person doesn't follow any people and companies yet"
  insightsOwn:    "Collect successful founders' insights and put them to action"
  insightsOther:  "This person hasn't added any insights yet"
  companiesOwn:   ->
    <span>
      Want to see your company on CloudChart? <a href="mailto:team@cloudchart.co?subject=I want to see my company on CloudChart">Let us know</a>
    </span>
  companiesOther: ->  
    <span>
      Does this person have a company you want to see on CloudChart? <a href="mailto:team@cloudchart.co?subject=I want to see a company on CloudChart">Let us know</a>
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
            favorites,
            system_roles
          }
        """

      user: ->
        """
          User {
            followed_activities,
            roles,
            pins,
            owned_companies,
            #{UserPins.getQuery('pins')},
            #{UserCompanies.getQuery('companies')}
          }
        """

  propTypes:
    uuid:   React.PropTypes.string.isRequired

  getInitialState: ->
    fetchDone:   false
    currentTab:  location.hash.substr(1) || null
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


  # Helpers
  #
  isLoaded: ->
    @state.fetchDone

  getMenuOptionClassName: (option) ->
    cx(active: @state.currentTab == option)

  getVisibleTabs: ->
    Immutable.OrderedMap(
      insights:  true
      feed:      true
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

  getInsightsCount: ->
    count = PinStore
      .filterByUserId(@props.uuid)
      .filter (pin) -> 
        pin.get('pinnable_id') && (pin.get('parent_id') || pin.get('content'))
      .size

  getCompaniesCount: ->
    count = CompanyStore.filterForUser(@props.uuid).size


  # Handlers
  #
  handleHashChange: ->
    currentTab = location.hash.substr(1)
    if @state.visibleTabs.contains(currentTab)
      @setState currentTab: currentTab


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
          { @renderTabName(tabName) }
        </a>
      </li>
    .toArray()

  renderMenu: ->
    <nav className="tabs">
      <ul>
        { @renderTabs() }
      </ul>
    </nav>

  renderEmptyTabText: (key) ->
    emptyTextKey = key + (if @isViewerProfile() then "Own" else "Other")
    renderedText = if _.isFunction(text = EmptyTabTexts[emptyTextKey]) then text() else text

    <p className="empty">
      { renderedText }
    </p>

  renderFeed: ->
    unless UserFeed.isEmpty()
      <UserFeed />
    else
      @renderEmptyTabText("feed")

  renderCompanies: ->
    unless UserCompanies.isEmpty(@props.uuid)
      <UserCompanies user_id = { @props.uuid } />
    else
      @renderEmptyTabText("companies")

  renderInsights: ->
    unless UserPins.isEmpty(@props.uuid)
      <UserPins user_id = { @props.uuid } showOnlyInsights = { !@isViewerProfile() } />
    else
      @renderEmptyTabText("insights")

  renderInsightsNumber: ->
    return null unless (insightsCount = @getInsightsCount()) > 0

    <strong>{ insightsCount }</strong>

  renderCompaniesNumber: ->
    return null unless (companiesCount = @getCompaniesCount()) > 0

    <strong>{ companiesCount }</strong>

  renderTabName: (key) ->
    switch key
      when 'insights'
        <span>Insights { @renderInsightsNumber() }</span>
      when 'companies'
        <span>Companies { @renderCompaniesNumber() }</span>
      when 'feed'
        "Feed"
      when 'settings'
        "Settings"

  renderContent: ->
    switch @state.currentTab
      when 'insights'
        @renderInsights()
      when 'companies'
        @renderCompanies()
      when 'feed'
        @renderFeed()
      when 'settings'
        <Settings uuid = { @props.uuid } />


  render: ->
    return null unless @isLoaded()

    <section className="user-profile">
      <header>
        <div className="cloud-columns cloud-columns-flex">
          <ProfileInfo uuid = { @props.uuid } />
          { @renderMenu() }
        </div>
      </header>
      { @renderContent() }
    </section>
