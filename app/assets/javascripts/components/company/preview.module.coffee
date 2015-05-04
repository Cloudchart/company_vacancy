# @cjsx React.DOM

GlobalState    = require('global_state/state')

CompanyStore   = require('stores/company_store.cursor')
BlockStore     = require('stores/block_store.cursor')
PostStore      = require('stores/post_store.cursor')
PinStore       = require('stores/pin_store')
RoleStore      = require('stores/role_store.cursor')
TaggingStore   = require('stores/tagging_store')
TagStore       = require('stores/tag_store')
TokenStore     = require('stores/token_store.cursor')
FavoriteStore  = require('stores/favorite_store.cursor')
UserStore      = require('stores/user_store.cursor')

CompanySyncApi = require('sync/company')

Logo           = require('components/company/logo')
People         = require('components/pinnable/block/people')

Buttons        = require('components/form/buttons')

pluralize      = require('utils/pluralize')

SyncButton     = Buttons.SyncButton
CancelButton   = Buttons.CancelButton

CompanyPreview = React.createClass

  displayName: 'CompanyPreview'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      company: ->
        """
          Company {
            followers,
            blocks,
            people,
            tags,
            taggings,
            public_posts {
              pins
            }
          }
        """

      viewer: ->
        """
          Viewer {
            company_invite_tokens,
            roles
          }
        """

      favorites: ->
        """
          Viewer {
            favorites
          }
        """

  fetchViewer: ->
    GlobalState.fetch(@getQuery('viewer'))

  fetchFavorites: (options={}) ->
    GlobalState.fetch(@getQuery('favorites'), options)


  # Component specifications
  #
  propTypes:
    onSyncDone:       React.PropTypes.func
    showFollowButton: React.PropTypes.bool
    uuid:             React.PropTypes.string.isRequired

  getDefaultProps: ->
    cursor:
      roles:  RoleStore.cursor.items
      tokens: TokenStore.cursor.items
    onSyncDone: ->
    showFollowButton: false

  getInitialState: ->
    sync: Immutable.Map()


  # Helpers
  #
  isLoaded: ->
    @cursor.tokens.deref(false)

  getTagNames: ->
    if (tags = @cursor.company.get('tag_names'))
      Immutable.Seq(tags)
        .sort (tagA, tagB) -> tagA.localeCompare(tagB)
        .take(5)
    else
      @cursor.tags
        .filter (tag) => @getTaggingIdSet().contains(tag.get('uuid'))
        .sort (tagA, tagB) -> tagA.get('name').localeCompare(tagB.get('name'))
        .take(5)
        .map (tag) -> tag.get('name')

  getTaggingIdSet: ->
    @cursor.taggings.deref(Immutable.Seq())
      .filter (tagging) => tagging.get('taggable_type') is 'Company' && tagging.get('taggable_id') is @props.uuid
      .map (tagging) -> tagging.get('tag_id')
      .toSet()

  getStrippedDescription: ->
    return "" unless @cursor.company.get('description')

    description = @cursor.company.get('description').replace(/(<([^>]+)>)/ig, " ").trim()

    if description.length > 170
      description = description.slice(0, 170) + "..."

    description

  getToken: ->
    TokenStore.findCompanyInvite(@props.uuid)

  getFavorite: ->
    FavoriteStore.filter (favorite) => 
      favorite.get('favoritable_id') == @props.uuid &&
      favorite.get('favoritable_type') == 'Company' &&
      favorite.get('user_id') == @cursor.viewer.get('uuid')
    .first()

  getPeopleIds: ->
    personBlock = BlockStore.filter (block) =>
      block.get('owner_type') == 'Company' &&
      block.get('owner_id') == @props.uuid &&
      block.get('identity_type') == 'Person'
    .sortBy (block) -> block.get('position')
    .first()

    if personBlock && (peopleIds = personBlock.get('identity_ids'))
      peopleIds.take(5).toSeq()
    else
      Immutable.Seq()

  getPosts: ->
    @cursor.posts.filter (post) =>
      post.get('owner_type') == 'Company' &&
      post.get('owner_id') == @props.uuid

  getPostsCount: ->
    unless pins_count = @cursor.company.get('posts_count')
      @getPosts().size || 0
    else
      pins_count

  getInsightsCount: ->
    unless insights_count = @cursor.company.get('insights_count')
      posts = @getPosts()

      @cursor.pins.filter (pin) ->
        pin.get('content') &&
        !pin.get('parent_id') &&
        posts.has pin.get('pinnable_id') 
      .size || 0
    else
      insights_count

  isViewerOwner: ->
    !!CompanyStore
      .filterForUser(@cursor.viewer.get('uuid'))
      .filter (company) => company.get('uuid') == @props.uuid
      .size


  # Handlers
  #
  handleFollowClick: (event) ->
    event.preventDefault()
    event.stopPropagation()

    @setState(sync: @state.sync.set('follow', true))

    CompanySyncApi.follow(@cursor.company.get('uuid'), @handleFollowDone, @handleFail.bind(@, 'unfollow'))

  handleDeclineClick: (event) ->
    event.preventDefault()
    event.stopPropagation()

    @setState(sync: @state.sync.set('decline', true))

    CompanySyncApi.cancelInvite(@cursor.company.get('uuid'), @getToken().get('uuid'), @handleInviteDone.bind(@, 'decline'), @handleFail.bind(@, 'decline'))

  handleAcceptClick: (event) ->
    event.preventDefault()
    event.stopPropagation()

    @setState(sync: @state.sync.set('accept', true))

    CompanySyncApi.acceptInvite(@cursor.company.get('uuid'), @getToken().get('uuid'))
      .then(@handleInviteDone.bind(@, 'accept'), @handleFail.bind(@, 'accept'))

  handleFollowDone: (syncKey) ->
    # TODO rewrite with grabbing only needed favorite
    @fetchFavorites(force: true).then => 
      @setState(sync: @state.sync.set('follow', false))

  handleInviteDone: (syncKey) ->
    @cursor.tokens.remove(@getToken().get('uuid'))
    @props.onSyncDone()
    @setState(sync: @state.sync.set(syncKey, false))

  handleFail: (syncKey) ->
    @setState(sync: @state.sync.set(syncKey, false))


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      blocks:    BlockStore.cursor.items
      company:   CompanyStore.cursor.items.cursor(@props.uuid)
      posts:     PostStore.cursor.items
      pins:      PinStore.cursor.items
      tags:      TagStore.cursor.items
      taggings:  TaggingStore.cursor.items
      tokens:    TokenStore.cursor.items
      favorites: FavoriteStore.cursor.items
      viewer:    UserStore.me()

    @fetchViewer() unless @isLoaded()


  # Renderers
  #
  renderTags: ->
    @getTagNames()
      .map (tag, index) -> <div key={ index } >#{ tag }</div>
      .toArray()

  renderInvitedLabel: ->
    return null unless @getToken()

    <li className="label">Invited</li>

  renderFollowButton: ->
    return null unless @props.showFollowButton && !@getFavorite() && !@isViewerOwner()

    <SyncButton
      className = "cc follow"
      onClick   = { @handleFollowClick }
      sync      = { @state.sync.get('follow') }
      text      = "Follow" />

  renderFollowedLabel: ->
    return null unless @getFavorite()

    <li className="label">Followed</li>

  renderPostsCount: ->
    return null if (count = @getPostsCount()) == 0

    <li>
      { pluralize(count, "post", "posts") }
    </li>

  renderInsightsCount: ->
    return null if (count = @getInsightsCount()) == 0

    <li>
      { pluralize(count || 0, "insight", "insights") }
    </li>

  renderInfo: ->
    <div className="info">
      <ul className="stats">
        { @renderInsightsCount() }
        { @renderPostsCount() }
      </ul>
      <ul className="labels">
        { @renderInvitedLabel() }
        { @renderFollowButton() }
        { @renderFollowedLabel() }
      </ul>
    </div>

  renderHeader: ->
    company = @cursor.company

    <header>
      <Logo 
        logoUrl = { company.get('logotype_url') }
        value   = { company.get('name') } />
      <h1>{ company.get('name') }</h1>
    </header>

  renderButtonsOrPeople: ->
    if @getToken()
      <div className="buttons">
        <SyncButton 
          className = "cc alert"
          iconClass = "fa-close"
          onClick   = { @handleDeclineClick }
          sync      = { @state.sync.get('decline') }
          text      = "Decline" />
        <SyncButton 
          className = "cc"
          iconClass = "fa-check"
          onClick   = { @handleAcceptClick }
          sync      = { @state.sync.get('accept') }
          text      = "Accept" />
      </div>
    else
      <People 
        key            = "people"
        ids            = { @getPeopleIds() } 
        showOccupation = { false }
        showLink       = { false } />

  renderFooter: ->
    <footer>
      { @renderButtonsOrPeople() }
    </footer>


  render: ->
    return null unless (company = @cursor.company.deref(false))

    <article className="company-preview cloud-card">
      <a href={ company.get('company_url') } className="company-preview-link for-group">
        { @renderHeader() }
        { @renderInfo() }
        <p className="description">
          { @getStrippedDescription() }
        </p>
        { @renderFooter() }
      </a>
    </article>


module.exports = CompanyPreview
