# @cjsx React.DOM

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

SyncButton     = Buttons.SyncButton
CancelButton   = Buttons.CancelButton

CompanyList = React.createClass

  displayName: 'CompanyPreview'

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

  getToken: ->
    TokenStore.findCompanyInvite(@cursor.company)

  getFavorite: ->
    FavoriteStore.findByCompany(@cursor.company)


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

  renderInfo: ->
    <div className="info">
      <ul className="stats">
        <li>
          { @cursor.company.get('posts_count') }
          <div className="round-button">
            <i className="fa fa-pencil"></i>
          </div>
        </li>
        <li>
          { @cursor.company.get('pins_count') }
          <div className="round-button">
            <i className="fa fa-thumb-tack"></i>
          </div>
        </li>
      </ul>
      <ul className="labels">
        {
          if @getToken()
            <li className="label">Invited</li>
        }
        {
          if @getFavorite()
            <li className="label">Followed</li>
        }
      </ul>
    </div>   

  renderHeader: ->
    company = @cursor.company

    <header>
      <Logo 
        logoUrl = { company.get('logotype_url') }
        value   = { company.get('name') } />
      {
        unless company.get('is_name_in_logo')
          <h1>{ company.get("name") }</h1>
      }
    </header>

  renderButtons: ->
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
      {
        if @getToken()
          @renderButtons()
      }
      <People key="people" items={ PersonStore.findByCompany(@props.uuid) } />
      <section key="tags" className="tags">{ @renderTags() }</section>
    </footer>


  render: ->
    return null unless @cursor.company.deref(false)

    company = @cursor.company

    <article className="company-preview cloud-card">
      <a href={ company.get('company_url') } className="company-preview-link">
        { @renderInfo() }
        { @renderHeader() }
        <div className="description" dangerouslySetInnerHTML={__html: company.get('description')}></div>
        { @renderFooter() }
      </a>
    </article>


module.exports = CompanyList
