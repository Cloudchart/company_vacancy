# @cjsx React.DOM

GlobalState    = require('global_state/state')

CompanyStore   = require('stores/company_store.cursor')
BlockStore     = require('stores/block_store.cursor')
PostStore      = require('stores/post_store.cursor')
PinStore       = require('stores/pin_store')
TaggingStore   = require('stores/tagging_store')
TagStore       = require('stores/tag_store')
TokenStore     = require('stores/token_store.cursor')
FavoriteStore  = require('stores/favorite_store.cursor')

CompanySyncApi = require('sync/company')

Logo           = require('components/company/logo')
People         = require('components/pinnable/block/people')

Buttons        = require('components/form/buttons')

pluralize      = require('utils/pluralize')

SyncButton     = Buttons.SyncButton
CancelButton   = Buttons.CancelButton

CompanyPreview = React.createClass

  displayName: 'CompanyPreview'

  mixins: [GlobalState.query.mixin]

  statics:

    queries:

      company: ->
        """
          Company {
            blocks,
            people,
            tags,
            taggings,
            public_posts {
              pins
            }
          }
        """  

  # Component specifications
  #
  propTypes:
    onSyncDone: React.PropTypes.func
    uuid:       React.PropTypes.string.isRequired

  getDefaultProps: ->
    onSyncDone: ->

  getInitialState: ->
    sync: false


  # Helpers
  #
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
    FavoriteStore.findByCompany(@props.uuid)

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


  # Handlers
  #
  handleDeclineClick: (event) ->
    event.preventDefault()
    event.stopPropagation()

    @setState(sync: true)

    CompanySyncApi.cancelInvite(@cursor.company.get('uuid'), @getToken().get('uuid'), @handleDone, @handleFail)

  handleAcceptClick: (event) ->
    event.preventDefault()
    event.stopPropagation()

    @setState(sync: true)

    CompanySyncApi.acceptInvite(@cursor.company.get('uuid'), @getToken().get('uuid'))
      .then(@handleDone, @handleFail)

  handleDone: ->
    @props.onSyncDone()

  handleFail: ->
    @setState(sync: false)


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


  # Renderers
  #
  renderTags: ->
    @getTagNames()
      .map (tag, index) -> <div key={ index } >#{ tag }</div>
      .toArray()

  renderInvitedLabel: ->
    return null unless @getToken()

    <li className="label">Invited</li>

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
        { @renderFollowedLabel() }
      </ul>
    </div>

  renderHeader: ->
    company = @cursor.company

    <header>
      <figure>
        <Logo 
          logoUrl = { company.get('logotype_url') }
          value   = { company.get('name') } />
      </figure>
      <h1>{ company.get('name') }</h1>
    </header>

  renderButtonsOrPeople: ->
    if @getToken()
      <div className="buttons">
        <SyncButton 
          className = "cc alert"
          iconClass = "fa-close"
          onClick   = { @handleDeclineClick }
          sync      = { @state.sync }
          text      = "Decline" />
        <SyncButton 
          className = "cc"
          iconClass = "fa-check"
          onClick   = { @handleAcceptClick }
          sync      = { @state.sync }
          text      = "Accept" />
      </div>
    else
      <People 
        key            = "people"
        ids            = { @getPeopleIds() } 
        showOccupation = { false } />

  renderFooter: ->
    <footer>
      { @renderButtonsOrPeople() }
      <section key="tags" className="tags">{ @renderTags() }</section>
    </footer>


  render: ->
    return null unless (company = @cursor.company.deref(false))

    <article className="company-preview cloud-card">
      <a href={ company.get('company_url') } className="company-preview-link">
        { @renderHeader() }
        { @renderInfo() }
        <p className="description">
          { @getStrippedDescription() }
        </p>
        { @renderFooter() }
      </a>
    </article>


module.exports = CompanyPreview
