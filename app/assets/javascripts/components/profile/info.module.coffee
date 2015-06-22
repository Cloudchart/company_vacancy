# @cjsx React.DOM


GlobalState     = require('global_state/state')

UserStore       = require('stores/user_store.cursor')
CompanyStore    = require('stores/company_store.cursor')
FavoriteStore   = require('stores/favorite_store.cursor')
PersonStore     = require('stores/person_store.cursor')
PinStore        = require('stores/pin_store')

UserSyncApi     = require('sync/user_sync_api')

pluralize       = require('utils/pluralize')

AutoSizingInput = require('components/form/autosizing_input')
PersonAvatar    = require('components/shared/person_avatar')

Buttons = require('components/form/buttons')
SyncButton = Buttons.SyncButton
AuthButton = Buttons.AuthButton

SyncApi = require('sync/user_sync_api')

KnownAttributes = Immutable.Seq(['avatar_url'])


module.exports  = React.createClass

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

      fetching_user: ->
        """
          User{}
        """

  propTypes:
    uuid:     React.PropTypes.string.isRequired

  getDefaultProps: ->
    cursor:
      users:     UserStore.cursor.items
      favorites: FavoriteStore.cursor.items

  fetchViewer: (options={}) ->
    GlobalState.fetch(@getQuery('viewer'), options)

  getInitialState: ->
    attributes:  Immutable.Map()
    isSyncing:   false

  getStateFromStores: ->
    favorite: FavoriteStore.findByUserForUser(@props.uuid, @cursor.viewer.get('uuid'))

  onGlobalStateChange: ->
    @setState @getStateFromStores()


  # Helpers
  #
  isLoaded: ->
    @cursor.user.deref(false)

  handleFetchDone: ->
    @setState
      attributes: @getAttributesFromCursor()

  getFavorite: ->
    @state.favorite

  getAttributesFromCursor: ->
    Immutable.Map().withMutations (attributes) =>
      KnownAttributes.forEach (name) =>
        attributes.set(name, @state.attributes.get(name) || @cursor.user.get(name, '') || '')

  update: (attributes) ->
    UserSyncApi.update(@cursor.user, @state.attributes.toJSON()).then @handleSubmitDone, @handleSubmitFail

  isViewerProfile: ->
    @props.uuid == @cursor.viewer.get('uuid')

  getRelatedPeople: ->
    companiesIds = CompanyStore.filterForUser(@props.uuid).map (company) -> company.get('uuid')

    people = PersonStore
      .filter (person) =>
        person.get('is_verified') && companiesIds.contains(person.get('company_id')) &&
        person.get('twitter') == @cursor.user.get('twitter')

  getOccupations: ->
    if (people = @getRelatedPeople()).size > 0
      people
        .map (person) ->
          occupation: person.get('occupation'),
          company:    CompanyStore.cursor.items.get(person.get('company_id')).get('name')
    else
      Immutable.Seq([
        occupation: @cursor.user.get('occupation')
        company: @cursor.user.get('company')
      ])


  # Handlers
  #
  handleAvatarChange: (file) ->
    newAttributes = @state.attributes.withMutations (attributes) ->
      attributes.remove('remove_avatar').set('avatar', file).set('avatar_url', URL.createObjectURL(file))

    @setState(attributes: newAttributes)
    @update(newAttributes)

  handleSubmitDone: ->
    GlobalState.fetch(@getQuery("fetching_user"), force: true, id: @props.uuid)

  handleFollowClick: ->
    @setState(isSyncing: true)

    if favorite = @getFavorite()
      SyncApi.unfollow(@props.uuid).then =>
        favoriteId = favorite.get('uuid')
        FavoriteStore.remove(favoriteId)
        @setState(isSyncing: false)
    else
      SyncApi.follow(@props.uuid).then =>
        # TODO rewrite with grabbing only needed favorite
        @fetchViewer(force: true).then => @setState(isSyncing: false)


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      user:   UserStore.cursor.items.cursor(@props.uuid)
      viewer: UserStore.me()

    @handleFetchDone()


  # Renderers
  #
  renderFollowButton: ->
    return null if @isViewerProfile()

    text = if @getFavorite() then 'Unfollow' else 'Follow'

    <AuthButton>
      <SyncButton
        className         = "cc follow-button"
        onClick           = { @handleFollowClick }
        text              = { text }
        sync              = { @state.isSyncing }
      />
    </AuthButton>

  renderOccupation: (item) ->
    strings = []
    strings.push item.occupation if item.occupation
    strings.push item.company if item.company

    strings.join(', ')

  renderOccupations: ->
    @getOccupations().map (item, index) =>
      <li key = { index }>
        { @renderOccupation(item) }
      </li>
    .toArray()

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
        <h1> { @cursor.user.get('full_name') } { @renderTwitter() } </h1>
        <ul className="occupations">
          { @renderOccupations() }
        </ul>
        <div className="spacer"></div>
        { @renderFollowButton() }
      </section>
    </section>
