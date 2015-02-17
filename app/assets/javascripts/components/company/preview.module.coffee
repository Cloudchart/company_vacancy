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

  getInitialState: ->
    @getStateFromStores()

  getStateFromStores: ->
    company: CompanyStore.cursor.items.get(@props.uuid)

  # Helpers
  #
  getPersonCount: ->
    PersonStore.findByCompany(@props.uuid).size

  # Renderers
  #
  renderTags: ->
    null
    # @state.company.get('tag_names')


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
                <span>{ @getPersonCount() }</span>
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
