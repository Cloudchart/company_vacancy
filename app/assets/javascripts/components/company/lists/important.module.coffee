# @cjsx React.DOM

GlobalState       = require('global_state/state')

CompanyStore      = require('stores/company_store.cursor')
UserStore         = require('stores/user_store.cursor')

CompanyList       = require('components/company/list')
CompanyPreview    = require('components/company/preview')


ImportantCompanies = React.createClass

  displayName: 'ImportantCompanies'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      viewer: ->
        """
          Viewer {
            roles,
            important_companies {
              #{CompanyPreview.getQuery('company')}
            },
            edges {
              important_companies_ids
            }
          }
        """


  fetch: (id) ->
    GlobalState.fetch(@getQuery('viewer'))


  # Helpers
  #
  getCompanies: ->
    UserStore.me().get('important_companies_ids', Immutable.Seq())
      .map (id) -> CompanyStore.get(id)


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      user:       UserStore.me()
      companies:  CompanyStore.cursor.items

    @fetch()


  # Renderers
  #

  renderHeader: ->
    return null unless @props.header
    <header className="cloud-columns cloud-columns-flex">{ @props.header }</header>


  renderDescription: ->
    return null unless @props.description
    <p className="cloud-columns cloud-columns-flex">{ @props.description }</p>


  render: ->
    return null unless (companies = @getCompanies()) and companies.size > 0

    <section className="featured-companies">
      { @renderHeader() }
      { @renderDescription() }
      <CompanyList companies={ companies.toArray() } />
    </section>


# Exports
#
module.exports = ImportantCompanies
