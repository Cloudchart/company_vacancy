# @cjsx React.DOM

GlobalState      = require('global_state/state')

CompanyStore     = require('stores/company_store.cursor')

CompanyPreview   = require('components/company/preview')

NodeRepositioner = require('utils/node_repositioner')


CompanyList = React.createClass

  displayName: 'CompanyList'

  mixins: [GlobalState.query.mixin, NodeRepositioner.mixin]

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
    uuid:           React.PropTypes.string
    ids:            React.PropTypes.instanceOf(Immutable.Seq)
    isInLegacyMode: React.PropTypes.bool

  getDefaultProps: ->
    isInLegacyMode: false

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

  getCompaniesIds: ->
    if @props.isInLegacyMode
      @props.ids
    else
      @cursor.companies.map (company) -> company.get('uuid')


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      companies: CompanyStore.cursor.items

    @fetch() unless (@isLoaded() || @props.isInLegacyMode)


  # Renderers
  #
  renderCompanies: ->
    @getCompaniesIds().map (id, index) =>
      <section key={index} className="cloud-column">
        <CompanyPreview 
          key        = { id }
          onSyncDone = { @props.onSyncDone }
          uuid       = { id } />
      </section>
    .toArray()


  render: ->
    return null unless (@isLoaded() || @props.isInLegacyMode)

    <section className="companies-list cloud-columns cloud-columns-flex">
      { @renderCompanies() }
    </section>


module.exports = CompanyList