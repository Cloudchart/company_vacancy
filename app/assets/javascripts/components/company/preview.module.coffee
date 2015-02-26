# @cjsx React.DOM

CompanyStore   = require('stores/company_store.cursor')
PersonStore    = require('stores/person_store.cursor')
TaggingStore   = require('stores/tagging_store')
TagStore       = require('stores/tag_store')
TokenStore     = require('stores/token_store.cursor')

CompanySyncApi = require('sync/company')

Logo           = require('components/company/logo')
People         = require('components/pinnable/block/people')

SyncButton     = require('components/form/buttons').SyncButton


CompanyList = React.createClass

  displayName: 'CompanyPreview'


  # Component specifications
  #
  propTypes:
    uuid:       React.PropTypes.string.isRequired
    onSyncDone: React.PropTypes.func

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
    if @cursor.company.deref(false)
      @cursor.tokens.filter((token) => token.get('owner_id') == @cursor.company.get('uuid')).toArray()[0]


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
    @setState(sync: false)
    @props.onSyncDone()

  handleFail: ->
    @setState(sync: false)


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      company:  CompanyStore.cursor.items.cursor(@props.uuid)
      people:   PersonStore.cursor.items
      tags:     TagStore.cursor.items
      taggings: TaggingStore.cursor.items
      tokens:   TokenStore.cursor.items


  # Renderers
  #
  renderTags: ->
    @cursor.tags
      .filter (tag) => @getTaggingIdSet().contains(tag.get('uuid'))
      .sort (tagA, tagB) -> tagA.get('name').localeCompare(tagB.get('name'))
      .map (tag, index) -> <div key={ index } >#{ tag.get('name') }</div>
      .toArray()

  renderButtons: ->
    <div className="buttons">
      <SyncButton 
        iconClass = "fa-close"
        onClick   = { @handleDeclineClick }
        sync      = { @state.sync }
        text      = "Decline" />
      <SyncButton 
        iconClass = "fa-check"
        onClick   = { @handleAcceptClick }
        sync      = { @state.sync }
        text      = "Accept" />
    </div>

  renderFooter: ->
    <footer>
      {
        if !@getToken()
          [
            <People key="people" items={ PersonStore.findByCompany(@props.uuid) } />
            <section key="tags" className="tags">{ @renderTags() }</section>
          ]
        else
          @renderButtons()
      }
    </footer>


  render: ->
    return null unless @cursor.company.deref(false)

    company = @cursor.company

    <article className="company-preview cloud-card">
      <a href={ company.get('company_url') } className="company-preview-link">
        <header>
          <Logo 
            logoUrl = { company.get('logotype_url') }
            value   = { company.get('name') } />
          <h1>{ company.get("name") }</h1>
        </header>
        <div className="description" dangerouslySetInnerHTML={__html: company.get('description')}></div>
        { @renderFooter() }
      </a>
    </article>


module.exports = CompanyList
