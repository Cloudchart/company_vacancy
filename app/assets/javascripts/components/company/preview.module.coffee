# @cjsx React.DOM

GlobalState    = require('global_state/state')

CompanyStore   = require('stores/company_store.cursor')
PersonStore    = require('stores/person_store.cursor')
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

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      company: ->
        """
          Company {
            people,
            tags,
            taggings
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
      company:   CompanyStore.cursor.items.cursor(@props.uuid)
      people:    PersonStore.cursor.items
      tags:      TagStore.cursor.items
      taggings:  TaggingStore.cursor.items
      tokens:    TokenStore.cursor.items
      favorites: FavoriteStore.cursor.items


  # Renderers
  #
  renderTags: ->
    @cursor.tags
      .filter (tag) => @getTaggingIdSet().contains(tag.get('uuid'))
      .sort (tagA, tagB) -> tagA.get('name').localeCompare(tagB.get('name'))
      .map (tag, index) -> <div key={ index } >#{ tag.get('name') }</div>
      .toArray()

  renderInvitedLabel: ->
    return null unless @getToken()

    <li className="label">Invited</li>

  renderFollowedLabel: ->
    return null unless @getFavorite()

    <li className="label">Followed</li>

  renderInfo: ->
    <div className="info">
      <ul className="stats">
        <li>
          { pluralize(@cursor.company.get('posts_count') || 0, "post", "posts") }
        </li>
        <li>
          { pluralize(@cursor.company.get('pins_count') || 0, "pin", "pins") }
        </li>
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

  renderButtons: ->
    return null unless @getToken()

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

  renderFooter: ->
    <footer>
      { @renderButtons() }
      <People 
        key            = "people"
        items          = { PersonStore.findByCompany(@props.uuid).take(5) }
        showOccupation = { false } />
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
