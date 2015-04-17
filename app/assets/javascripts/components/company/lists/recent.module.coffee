# @cjsx React.DOM

GlobalState      = require('global_state/state')

CompanyStore     = require('stores/company_store.cursor')

CompanyList      = require('components/company/list')
CompanyPreview   = require('components/company/preview')


UserCompanies = React.createClass

  displayName: 'RecentCompanies'

  mixins: [GlobalState.query.mixin]

  statics:

    queries:

      companies: ->
        """
          Viewer {
            recent_companies {
              #{CompanyPreview.getQuery('company')}
            }
          }
        """

  getInitialState: ->
    isLoaded: false

  fetch: (id) ->
    GlobalState.fetch(@getQuery('companies'))


  # Helpers
  #
  getCompanies: ->
    CompanyStore
      .filter (company) -> company.get('is_published')
      .sortBy (company) -> company.get('created_at')
      .reverse()
      .take(4)
      .toArray()


  # Lifecycle methods
  #
  componentWillMount: ->   
    @fetch().then => @setState(isLoaded: true)


  # Renderers
  #
  render: ->
    return null unless @state.isLoaded

    <CompanyList companies = { @getCompanies() } />


module.exports = UserCompanies