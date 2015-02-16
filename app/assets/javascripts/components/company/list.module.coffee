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
  renderCounter: ->
    <div className="counter">
      <h1>{ @state.companies.size } companies</h1>
    </div>

  renderCompanies: ->
    @state.companies.map (company) ->
      <CompanyPreview 
        key  = { company.get('uuid') }
        uuid = { company.get('uuid') } />


  render: ->
    <li className="companies-search">
      { @renderCounter() }
      <div className="result">
        { @renderCompanies() }
      </div>
    </li>


module.exports = CompanyList
