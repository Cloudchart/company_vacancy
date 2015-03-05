# @cjsx React.DOM

GlobalState    = require('global_state/state')

CompanyStore   = require('stores/company_store.cursor')

CompanyPreview = require('components/company/preview')


CompanyList = React.createClass

  displayName: 'CompanyList'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      companies: ->
        """
          User {
            owned_companies {
              #{CompanyPreview.getQuery('company')}
            }
          }
        """


  # Component specifications
  #
  propTypes:
    uuid: React.PropTypes.string.isRequired

  getInitialState: ->
    loaders: Immutable.Map()  

  fetch: ->
    GlobalState.fetch(@getQuery('companies'), id: @props.uuid).then =>
      @setState
        loaders: @state.loaders.set('companies', true)


  # Helpers
  #
  isLoaded: ->
    @state.loaders.get('companies') == true


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      companies: CompanyStore.cursor.items

    @fetch() unless @isLoaded()


  # Renderers
  #
  renderCompanies: ->
    @cursor.companies.map (company, index) =>
      <section key={index} className="cloud-column">
        <CompanyPreview 
          key        = { company.get('uuid') }
          onSyncDone = { @props.onSyncDone }
          uuid       = { company.get('uuid') } />
      </section>
    .toArray()


  render: ->
    return null unless @isLoaded()

    <section className="companies-list cloud-columns cloud-columns-flex">
      { @renderCompanies() }
    </section>


module.exports = CompanyList