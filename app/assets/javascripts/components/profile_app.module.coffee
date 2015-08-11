# @cjsx React.DOM

GlobalState        = require('global_state/state')

ProfileInfo         = require('components/profile/info')
UserPins            = require('components/pinboards/pins/user')
UserInsights        = require('components/profile/insights')
UserCompanies       = require('components/company/lists/user')
UserFeed            = require('components/user/feed')
UserPinboards       = require('components/pinboards/lists/user')
FavoriteInsights    = require('components/profile/favorite_insights')
Settings            = require('components/profile/settings')
TabNav              = require('components/shared/tab_nav')

UserStore           = require('stores/user_store.cursor')
PinStore            = require('stores/pin_store')
PinboardStore       = require('stores/pinboard_store')
CompanyStore        = require('stores/company_store.cursor')

Constants           = require('constants')

EmptyMap = Immutable.Map({})

EmptyTabTexts =
  feedOwn:        "Follow people and companies you're interested in to learn from them."
  feedOther:      "This person doesn't follow any people and companies yet."
  insightsOwn:    "Add helpful insights. Share with your team and the community."
  insightsOther:  "This person hasn't added any insights yet."
  pinboardsOwn:   "Follow our most popular collections to start, or, create your own."
  pinboardsOther: "This person has no collections yet."
  companiesOwn:   ->
    <span>
      Want to see your company on { Constants.SITE_NAME }? <a href="mailto:#{Constants.REPLY_TO_EMAIL}?subject=I want to see my company on #{Constants.SITE_NAME}">Let us know</a>
    </span>
  companiesOther: ->
    <span>
      Does this person have a company you want to see on { Constants.SITE_NAME }? <a href="mailto:#{Constants.REPLY_TO_EMAIL}?subject=I want to see a company on #{Constants.SITE_NAME}">Let us know</a>
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
            system_roles,
            roles
          }
        """

      user: ->
        """
          User {
            #{UserPinboards.getQuery('pinboards')},
            #{UserCompanies.getQuery('user')},
            edges {
              insights_ids,
              favorite_insights_ids,
              is_editable
            }
          }
        """

  propTypes:
    uuid:   React.PropTypes.string.isRequired

  getInitialState: ->
    fetchDone:   false
    currentTab:  null

  fetchViewer: (options={}) ->
    GlobalState.fetch(@getQuery('viewer'), options)


  fetchUser: ->
    GlobalState.fetch(@getQuery('user'), id: @props.uuid).then =>
      user = UserStore.get(@props.uuid)

      @setState
        insights_count:           user.get('insights_ids').size
        favorite_insights_count:  user.get('favorite_insights_ids').size


  fetch: ->
    Promise.all([@fetchUser(), @fetchViewer()]).then =>
      @setState
        fetchDone:   true


  # Helpers
  #
  isLoaded: ->
    @state.fetchDone

  isViewerProfile: ->
    @props.uuid == @cursor.viewer.get('uuid')


  getInsightsNumber: ->
    @cursor.user.get('insights_ids').size


  getCompaniesNumber: ->
    UserCompanies.companiesCount(@props.uuid)


  getPinboardsNumber: ->
    PinboardStore.filterUserPinboards(@props.uuid).size


  getFavoriteInsightsCount: ->
    @cursor.user.get('favorite_insights_ids').size


  # Handlers
  #
  handleTabChange: (tab) ->
    @setState currentTab: tab


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      companies:  CompanyStore.cursor.items
      pins:       PinStore.cursor.items
      viewer:     UserStore.me()
      user:       UserStore.cursor.items.cursor(@props.uuid)

    @fetch() unless @isLoaded()


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

  renderCompanies: ->
    unless @getCompaniesNumber() == 0
      <UserCompanies user_id = { @props.uuid } />
    else
      @renderEmptyTabText("companies")


  renderFavoriteInsights: ->
    return null if @state.favorite_insights_count == 0

    <section key='favorite-insights' className='cc-container-common'>
      <header>
        <h1>Starred Insights</h1>
      </header>
      <FavoriteInsights user={ @props.uuid } />
    </section>



  renderInsights: ->
    insights_count          = @getInsightsNumber()
    favorite_insights_count = @getFavoriteInsightsCount()
    counter                 = insights_count + favorite_insights_count

    if counter > 0
      [
        <UserInsights user={ @props.uuid } />
        @renderFavoriteInsights()
      ]
    else
      @renderEmptyTabText("insights")


  renderPinboards: ->
    if UserPinboards.isEmpty(@props.uuid)
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

      when 'companies'
        @renderCompanies()

      when 'settings'
        <Settings uuid = { @props.uuid } />

      when 'favorite_insights'
        <FavoriteInsights user={ @props.uuid } />

      else
        null


  gatherTabs: ->
    tabs = []

    companies_count         = @getCompaniesNumber()
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

    tabs.push
      id:       'companies'
      title:    'Companies'
      counter:  ['', '' + companies_count][~~!!companies_count]

    # tabs.push
    #   id:       'favorite_insights'
    #   title:    'Starred'
    #   counter:  ['', '' + favorite_insights_count][~~!!favorite_insights_count]

    if @cursor.user.get('is_editable')
      tabs.push
        id:       'settings'
        title:    'Settings'

    tabs


  render: ->
    return null unless @isLoaded()

    <section className="user-profile">
      <header>
        <div className="cloud-columns cloud-columns-flex">
          <ProfileInfo uuid = { @props.uuid } />
        </div>
        <TabNav tabs={ @gatherTabs() } currentTab={ @state.currentTab } onChange={ @handleTabChange } />
      </header>
      { @renderContent() }
    </section>
