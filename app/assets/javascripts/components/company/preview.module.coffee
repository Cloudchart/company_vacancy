# @cjsx React.DOM

CompanyStore  = require('stores/company_store.cursor')
PersonStore   = require('stores/person_store.cursor')
TaggingStore  = require('stores/tagging_store')
TagStore      = require('stores/tag_store')

Logo          = require('components/company/logo')
People        = require('components/pinnable/block/people')

CompanyList = React.createClass

  displayName: 'CompanyPreview'


  # Component specifications
  #
  propTypes:
    uuid: React.PropTypes.string.isRequired

  getDefaultProps: ->
    cursor:
      people:   PersonStore.cursor.items
      tags:     TagStore.cursor.items
      taggings: TaggingStore.cursor.items

  getInitialState: ->
    @getStateFromStores()

  getStateFromStores: ->
    company:      CompanyStore.cursor.items.get(@props.uuid)
    taggingIds:   @getTaggingIdSet()       


  # Helpers
  #
  taggingDeref: ->
    @props.cursor.taggings.deref(Immutable.Seq())

  getTaggingIdSet: ->
    @taggingDeref()
      .filter (tagging) => tagging.get('taggable_type') is 'Company' && tagging.get('taggable_id') is @props.uuid
      .map (tagging) -> tagging.get('tag_id')
      .toSet()


  # Renderers
  #
  renderTags: ->
    @props.cursor.tags
      .filter (tag) => @state.taggingIds.contains(tag.get('uuid'))
      .sort (tagA, tagB) -> tagA.get('name').localeCompare(tagB.get('name'))
      .map (tag) -> <div>#{ tag.get('name') }</div>
      .toArray()


  render: ->
    return null if !@state.company

    company = @state.company

    <article className="company-preview cloud-card">
      <a href={ company.get('company_url') } className="company-preview-link">
        <header>
          <Logo 
            logoUrl   = { company.get('logotype_url') }
            value     = { company.get('name') } />
          <h1>{ company.get("name") }</h1>
        </header>
        <div className="description" dangerouslySetInnerHTML={__html: company.get('description')}></div>
        <footer>
          <People items={ PersonStore.findByCompany(@props.uuid) } />
          <section className="tags">{ @renderTags() }</section>
        </footer>
      </a>
    </article>


module.exports = CompanyList
