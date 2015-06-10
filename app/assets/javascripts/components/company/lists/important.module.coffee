# @cjsx React.DOM

GlobalState      = require('global_state/state')

CompanyStore     = require('stores/company_store.cursor')

CompanyList      = require('components/company/list')
CompanyPreview   = require('components/company/preview')


UserCompanies = React.createClass

  displayName: 'ImportantCompanies'

  mixins: [GlobalState.query.mixin]

  statics:

    queries:

      companies: ->
        """
          Viewer {
            roles,
            important_companies {
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
      .filter (company) -> company.get('is_important')
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
  renderHeader: ->
    return null unless @props.header

    <header className="cloud-columns cloud-columns-flex">{ @props.header }</header>

  renderDescription: ->
    return null unless @props.description

    <p className="cloud-columns cloud-columns-flex">{ @props.description }</p>

  
  render: ->
    return null unless @state.isLoaded

    <section className="featured-companies">
      { @renderHeader() }
      { @renderDescription() }
      <CompanyList companies = { @getCompanies() } />
    </section>



module.exports = UserCompanies