# @cjsx React.DOM


GlobalState     = require('global_state/state')

UserStore       = require('stores/user_store.cursor')
CompanyStore    = require('stores/company_store.cursor')
PinStore        = require('stores/pin_store')

UserSyncApi     = require('sync/user_sync_api')

pluralize       = require('utils/pluralize')

AutoSizingInput = require('components/form/autosizing_input')
PersonAvatar    = require('components/shared/person_avatar')

KnownAttributes = Immutable.Seq(['avatar_url'])


module.exports  = React.createClass

  # Component specifications
  #
  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:
      user: ->
        """
          User {
            roles,
            pins,
            published_companies
          }
        """

      fetching_user: ->
        """
          User
        """

  propTypes:
    uuid:     React.PropTypes.string.isRequired

  getDefaultProps: ->
    cursor: UserStore.cursor.items

  getInitialState: ->
    attributes: Immutable.Map()
    fetchDone:  false

  fetch: ->
    GlobalState.fetch(@getQuery('user'), id: @props.uuid).then =>
      @handleFetchDone()


  # Helpers
  #
  isLoaded: ->
    @cursor.user.deref(false)

  handleFetchDone: ->
    @setState
      attributes: @getAttributesFromCursor()

  getAttributesFromCursor: ->
    Immutable.Map().withMutations (attributes) =>
      KnownAttributes.forEach (name) =>
        attributes.set(name, @state.attributes.get(name) || @cursor.user.get(name, '') || '')

  getInsightsCount: ->
    count = PinStore
      .filterByUserId(@props.uuid)
      .filter (pin) -> pin.get('pinnable_id') && !pin.get('parent_id') && pin.get('content')
      .size

    if count > 0
      pluralize(count, 'insight', 'insights')

  getCompaniesCount: ->
    count = CompanyStore.filterForUser(@props.uuid).size

    if count > 0
      pluralize(count, 'company', 'companies')

  update: (attributes) ->
    UserSyncApi.update(@cursor.user, @state.attributes.toJSON()).then @handleSubmitDone, @handleSubmitFail


  # Handlers
  #
  handleAvatarChange: (file) ->
    newAttributes = @state.attributes.withMutations (attributes) ->
      attributes.remove('remove_avatar').set('avatar', file).set('avatar_url', URL.createObjectURL(file))

    @setState(attributes: newAttributes)
    @update(newAttributes)

  handleSubmitDone: ->
    GlobalState.fetch(@getQuery("fetching_user"), force: true, id: @props.uuid)
    

  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor = 
      user:       UserStore.cursor.items.cursor(@props.uuid)

    if @isLoaded() then @handleFetchDone() else @fetch() 

  # Renderers
  #
  renderOccupation: ->
    strings = []
    strings.push occupation if (occupation = @cursor.user.get('occupation'))
    strings.push company if (company = @cursor.user.get('company'))

    <div className="occupation">
      { strings.join(', ') }
    </div>

  renderStats: ->
    counters = []

    if companiesCount = @getCompaniesCount() then counters.push(companiesCount)
    if insightsCount = @getInsightsCount() then counters.push(insightsCount)

    <div className="stats">{ counters.join(', ') }</div>

  renderTwitter: ->
    return null unless (twitterHandle = @cursor.user.get('twitter'))

    <a className="twitter" href={ "https://twitter.com/" + twitterHandle } target="_blank">@{ twitterHandle }</a>


  render: ->
    return null unless @isLoaded()

    <section className="info">
      <PersonAvatar
        avatarURL  =  { @state.attributes.get('avatar_url') }
        onChange   =  { @handleAvatarChange }
        readOnly   =  { !@cursor.user.get('is_editable') }
        value      =  { @cursor.user.get('full_name') }
        withCamera =  { true } />
      <section className="personal">
        <h1> { @cursor.user.get('full_name') } </h1>
        { @renderOccupation() }
        <div className="spacer"></div>
        { @renderStats() }
        { @renderTwitter() }
      </section>
    </section>
