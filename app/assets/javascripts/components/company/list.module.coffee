# @cjsx React.DOM

GlobalState = require('global_state/state')

CompanyStore   = require('stores/company_store.cursor')

CompanyPreview = require('components/company/preview')


CompanyList = React.createClass

  displayName: 'CompanyList'


  # Component specifications
  #
  propTypes:
    headerText:    React.PropTypes.string
    companiesIds:  React.PropTypes.instanceOf(Immutable.Seq).isRequired

  getDefaultProps: ->
    headerText: ''

  getInitialState: ->
    @getStateFromStores(@props)

  getStateFromStores: (props) ->
    companies: CompanyStore.cursor.items.deref(Immutable.Seq()).filter((company) => props.companiesIds.contains(company.get('uuid'))).toSeq()


  # Helpers
  #
  getHeaderText: ->
    if @props.headerText
      @props.headerText
    else
      "#{@state.companies.size} companies"


  # LifecycleMethods
  #
  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))


  # Renderers
  #
  renderHeader: ->
    <header>
      <h1>{ @getHeaderText() }</h1>
    </header>

  renderCompanies: ->
    result = @state.companies.map (company) ->
      <CompanyPreview 
        key  = { company.get('uuid') }
        uuid = { company.get('uuid') } />
    .toArray()


  render: ->
    return null if @state.companies.size == 0

    <section className="companies-list">
      { @renderHeader() }
      <div>
        { @renderCompanies() }
      </div>
    </section>


module.exports = CompanyList
