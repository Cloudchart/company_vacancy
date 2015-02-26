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
    onSyncDone:    React.PropTypes.func

  getDefaultProps: ->
    headerText: ''
    onSyncDone: ->

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
    <header>{ @getHeaderText() }</header>

  renderCompanies: ->
    result = @state.companies.map (company, index) =>
      <section key={index} className="cloud-column">
        <CompanyPreview 
          key        = { company.get('uuid') }
          uuid       = { company.get('uuid') }
          onSyncDone = { @props.onSyncDone } />
      </section>
    .toArray()


  render: ->
    return null if @state.companies.toArray().length == 0

    <section className="companies-list cloud-columns cloud-columns-flex">
      { @renderHeader() }
      { @renderCompanies() }
    </section>


module.exports = CompanyList
