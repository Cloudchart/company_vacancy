# @cjsx React.DOM

CompanyStore  = require('stores/company_store.cursor')
PersonStore   = require('stores/person_store.cursor')
TagStore      = require('stores/tag_store.cursor')

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
    companies: @props.cursor.companies.deref(Immutable.Seq())

  onGlobalStateChange: ->
    @setState  @getStateFromStores()

  # Helpers
  #
  getPersonCount: ->
    0

  # Renderers
  #
  renderCompanies: ->
    @state.companies.map (company) ->
      <CompanyPreview 
        uuid = { company.get('uuid') } />

  renderTags: ->
    null


  render: ->
    company = @state.company

    <div className="company-preview">
      <a href="" className="company-preview-link">
        <header>
          <Avatar 
            avatarURL = { company.get('logotype_url') }
            value     = { company.get('name') } />
        </header>
        <section class="middle">
          <div class="left">
            <div class="name">
              { company.get("name") }
            </div>
            <div class="description">
              { company.get("description") }
            </div>
          </div>
          <div class="right">
            <div class="size">
              <div class="vacancies">
                <span>0</span>
                <i class="fa fa-male"></i>
              </div>
              <div class="people">
                <span>{ @getPersonCount() }</span>
                <i class="fa fa-male"></i>
              </div>
            </div>
          </div>
        </section>
        <section class="bottom">
          <p> { @renderTags() } </p>
        </section>
      </a>
    </div>


module.exports = CompanyList
