# @cjsx React.DOM

GlobalState      = require('global_state/state')

CompanyStore     = require('stores/company_store.cursor')

CompanyPreview   = require('components/company/preview')

NodeRepositioner = require('utils/node_repositioner')


CompanyList = React.createClass

  displayName: 'CompanyList'

  mixins: [GlobalState.query.mixin]

  statics:

    queries:

      companies: ->
        """
          User {
            roles,
            published_companies {
              #{CompanyPreview.getQuery('company')}
            }
          }
        """

    isEmpty: (user_id) ->
      !CompanyStore.filterForUser(user_id).size


  # Component specifications
  #
  propTypes:
    user_id:        React.PropTypes.string
    ids:            React.PropTypes.instanceOf(Immutable.Seq)
    isInLegacyMode: React.PropTypes.bool
    onSyncDone:     React.PropTypes.func

  getDefaultProps: ->
    isInLegacyMode: false
    onSyncDone:     ->


  # Helpers
  #
  isLoaded: ->
    @cursor.companies.deref(false)

  getCompaniesIds: ->
    if @props.isInLegacyMode
      @props.ids
    else
      CompanyStore
        .filterForUser(@props.user_id)
        .sortBy (company) -> company.get('name')
        .map (company) -> company.get('uuid')


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      companies: CompanyStore.cursor.items


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