# @cjsx React.DOM

GlobalState = require('global_state/state')

CompanyStore   = require('stores/company_store.cursor')

CompanyPreview = require('components/company/preview')


CompanyList = React.createClass

  displayName: 'CompanyList'

  mixins: [GlobalState.mixin]


  # Component specifications
  #
  getDefaultProps: ->
    cursor:
      companies: CompanyStore.cursor.items

  getInitialState: ->
    @getStateFromStores()

  getStateFromStores: ->
    companies: @props.cursor.companies.deref(Immutable.Seq())

  onGlobalStateChange: ->
    @setState  @getStateFromStores()


  # Renderers
  #
  renderHeader: ->
    <header>
      <h1>{ @state.companies.size } companies</h1>
    </header>

  renderCompanies: ->
    result = @state.companies.map (company) ->
      <CompanyPreview 
        key  = { company.get('uuid') }
        uuid = { company.get('uuid') } />


  render: ->
    return null if @state.companies.size == 0

    <section className="companies-list">
      { @renderHeader() }
      <div>
        { @renderCompanies().toArray() }
      </div>
    </section>


module.exports = CompanyList
