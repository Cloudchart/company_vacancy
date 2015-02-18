# @cjsx React.DOM

CompanyStore  = require('stores/company_store.cursor')
PersonStore   = require('stores/person_store.cursor')
TaggingStore  = require('stores/tagging_store')
TagStore      = require('stores/tag_store')

Avatar        = require('components/avatar')

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
    personCount:  PersonStore.findByCompany(@props.uuid).size || 0
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
      .map (tag) -> "##{tag.get('name')}"
      .sort (tagA, tagB) -> tagA.localeCompare(tagB)
      .join(", ")


  render: ->
    return null if !@state.company

    company = @state.company

    <article className="company-preview">
      <a href={ company.get('company_url') } className="company-preview-link">
        <header>
          <Avatar 
            avatarURL = { company.get('logotype_url') }
            value     = { company.get('name') } />
        </header>
        <section className="middle">
          <div className="left">
            <div className="name">
              { company.get("name") }
            </div>
            <div className="description">
              { company.get("description") }
            </div>
          </div>
          <div className="right">
            <div className="size">
              <div className="vacancies">
                <span>0</span>
                <i className="fa fa-male"></i>
              </div>
              <div className="people">
                <span>{ @state.personCount }</span>
                <i className="fa fa-male"></i>
              </div>
            </div>
          </div>
        </section>
        <footer>
          <p> { @renderTags() } </p>
        </footer>
      </a>
    </article>


module.exports = CompanyList
