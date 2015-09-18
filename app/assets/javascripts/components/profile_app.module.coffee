# @cjsx React.DOM

GlobalState        = require('global_state/state')

ProfileInfo         = require('components/profile/info')
UserPins            = require('components/pinboards/pins/user')
UserInsights        = require('components/profile/insights')
UserFavorites       = require('components/profile/favorites')
UserFeed            = require('components/user/feed')
UserPinboards       = require('components/pinboards/lists/user')
FavoriteInsights    = require('components/profile/favorite_insights')
Settings            = require('components/profile/settings')
TabNav              = require('components/shared/tab_nav')

UserStore           = require('stores/user_store.cursor')
PinStore            = require('stores/pin_store')
PinboardStore       = require('stores/pinboard_store')

Constants           = require('constants')

EmptyMap = Immutable.Map({})

EmptyTabTexts =
  feedOwn:        "Follow people and companies you're interested in to learn from them."
  feedOther:      "This person doesn't follow any people and companies yet."
  insightsOwn:    "Add helpful insights. Share with your team and the community."
  insightsOther:  "This person hasn't added any insights yet."
  pinboardsOwn:   "Follow our most popular collections to start, or, create your own."
  pinboardsOther: "This person has no collections yet."

cx = React.addons.classSet


# Main component
#
module.exports = React.createClass

  displayName: 'ProfileApp'
  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  propTypes:
    uuid:   React.PropTypes.string.isRequired

  statics:
    queries:
      user: ->
        """
          User {
            #{UserPinboards.getQuery('pinboards')},
            #{UserFavorites.getQuery('user')},
            edges {
              insights_ids,
              favorite_insights_ids,
              is_editable
            }
          }
        """

  fetch: ->
    GlobalState.fetch(@getQuery('user'), id: @props.uuid).then =>
      user = UserStore.get(@props.uuid)

      @setState
        insights_count: user.get('insights_ids').size
        favorite_insights_count: user.get('favorite_insights_ids').size
        ready: true


  # Component specifications
  #
  getInitialState: ->
    ready:   false
    currentTab:  null


  # Helpers
  #
  isViewerProfile: ->
    @props.uuid == @cursor.viewer.get('uuid')

  getInsightsNumber: ->
    @cursor.user.get('insights_ids').size

  getPinboardsNumber: ->
    @cursor.user.get('available_pinboards_ids').size

  getFavoriteInsightsCount: ->
    @cursor.user.get('favorite_insights_ids').size

  getFavoritePinboardsCount: ->
    @cursor.user.get('favorite_pinboards_ids').size

  getFavoriteUsersCount: ->
    @cursor.user.get('favorite_users_ids').size


  # Handlers
  #
  handleTabChange: (tab) ->
    @setState currentTab: tab


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      viewer: UserStore.me()
      user: UserStore.cursor.items.cursor(@props.uuid)

  componentDidMount: ->
    @fetch()


  # Renderers
  #
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

  renderFavoriteInsights: ->
    return null if @state.favorite_insights_count == 0

    <section key='favorite-insights' className='cc-container-common'>
      <header>
        <h1>Starred Insights</h1>
      </header>
      <FavoriteInsights key = { 'favirite-insights' } user={ @props.uuid } />
    </section>

  renderInsights: ->
    insights_count          = @getInsightsNumber()
    favorite_insights_count = @getFavoriteInsightsCount()
    counter                 = insights_count + favorite_insights_count

    if counter > 0
      [
        <UserInsights key={ 'user-insights' } user={ @props.uuid } />
        @renderFavoriteInsights()
      ]
    else
      @renderEmptyTabText("insights")

  renderPinboards: ->
    if @getPinboardsNumber() == 0 #UserPinboards.isEmpty(@props.uuid)
      @renderEmptyTabText("pinboards")
    else
      <section className="cc-container-common">
        <UserPinboards user_id = { @props.uuid } />
      </section>


  renderContent: ->
    switch @state.currentTab

      when 'collections'
        @renderPinboards()

      when 'insights'
        @renderInsights()

      when 'following'
        <UserFavorites user = { @props.uuid } />

      when 'settings'
        <Settings uuid = { @props.uuid } />

      when 'favorite_insights'
        <FavoriteInsights user={ @props.uuid } />

      else
        null


  gatherTabs: ->
    tabs = []

    favorite_pinboards_count = @getFavoritePinboardsCount()
    favorite_users_count = @getFavoriteUsersCount()
    favorites_count = favorite_pinboards_count + favorite_users_count

    insights_count          = @getInsightsNumber()
    collections_count       = @getPinboardsNumber()
    favorite_insights_count = @getFavoriteInsightsCount()

    insights_count          = insights_count + favorite_insights_count

    tabs.push
      id:       'collections'
      title:    'Collections'
      counter:  ['', '' + collections_count][~~!!collections_count]

    tabs.push
      id:       'insights'
      title:    'Insights'
      counter:  ['', '' + insights_count][~~!!insights_count]

    if favorites_count > 0
      tabs.push
        id: 'following'
        title: 'Following'
        counter: ['', '' + favorites_count][~~!!favorites_count]

    if @cursor.user.get('is_editable')
      tabs.push
        id:       'settings'
        title:    'Settings'

    tabs


  render: ->
    return null unless @state.ready

    <section className="user-profile">
      <header>
        <div className="cloud-columns cloud-columns-flex">
          <ProfileInfo uuid = { @props.uuid } />
        </div>
        <TabNav tabs={ @gatherTabs() } currentTab={ @state.currentTab } onChange={ @handleTabChange } />
      </header>
      { @renderContent() }
    </section>
