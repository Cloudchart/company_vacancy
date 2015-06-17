# @cjsx React.DOM

GlobalState        = require('global_state/state')

ProfileInfo        = require('components/profile/info')
UserPins           = require('components/pinboards/pins/user')
UserCompanies      = require('components/company/lists/user')
UserFeed           = require('components/user/feed')
UserPinboards      = require('components/pinboards/lists/user')
Settings           = require('components/profile/settings')
Tabs               = require('components/profile/tabs')

UserStore          = require('stores/user_store.cursor')
PinStore           = require('stores/pin_store')
PinboardStore      = require('stores/pinboard_store')
CompanyStore       = require('stores/company_store.cursor')


EmptyTabTexts =
  feedOwn:        "Follow people and companies you're interested in to learn from them"
  feedOther:      "This person doesn't follow any people and companies yet"
  insightsOwn:    "Collect successful founders' insights and put them to action"
  insightsOther:  "This person hasn't added any insights yet"
  pinboardsOwn:   "Follow our most popular collections to start, or, create your own"
  pinboardsOther: "This person has no collections yet"
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
            system_roles,
            roles
          }
        """

      user: ->
        """
          User {
            followed_activities,
            roles,
            pins,
            #{UserPins.getQuery('pins')},
            #{UserPinboards.getQuery('pinboards')},

            #{UserCompanies.getQuery('user')}
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
    GlobalState.fetch(@getQuery('user'), id: @props.uuid)

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
    count = PinStore
      .filterPinsForUser(@props.uuid, onlyInsights: true)
      .size


  getCompaniesNumber: ->
    UserCompanies.companiesCount(@props.uuid)


  getPinboardsNumber: ->
    PinboardStore.filterUserPinboards(@props.uuid).size


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

  renderInsights: ->
    unless UserPins.isEmpty(@props.uuid, onlyInsights: true)
      <UserPins user_id = { @props.uuid } showOnlyInsights = { !@isViewerProfile() } />
    else
      @renderEmptyTabText("insights")

  renderPinboards: ->
    unless UserPinboards.isEmpty(@props.uuid)
      <UserPinboards user_id = { @props.uuid } />
    else
      @renderEmptyTabText("pinboards")

  renderContent: ->
    switch @state.currentTab
      when 'collections'
        @renderPinboards()
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
          <Tabs
            companiesNumber = { @getCompaniesNumber() }
            insightsNumber  = { @getInsightsNumber() }
            pinboardsNumber = { @getPinboardsNumber() }
            canEdit         = { @cursor.user.get('is_editable') }
            onChange        = { @handleTabChange } />
        </div>
      </header>
      { @renderContent() }
    </section>
