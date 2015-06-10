# @cjsx React.DOM

GlobalState       = require('global_state/state')


CompanyStore      = require('stores/company_store.cursor')
RoleStore         = require('stores/role_store.cursor')
UserStore         = require('stores/user_store.cursor')


CompanyList       = require('components/company/list')
CompanyPreview    = require('components/company/preview')


UserCompanies = React.createClass

  displayName: 'CompanyList'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      companies: ->
        """
          User {
            roles,
            companies_through_roles {
              #{CompanyPreview.getQuery('company')}
            },
            edges {
              companies_through_roles
            }
          }
        """

  # Component specifications
  #
  propTypes:
    user_id: React.PropTypes.string.isRequired


  # Helpers
  #
  isLoaded: ->
    @cursor.companies.deref(false)


  getCompanies: ->
    @cursor.user.get('companies_through_roles', Immutable.Seq())
      .sortBy (item) -> item.get('name')
      .map (item) -> CompanyStore.get(item.get('id'))
      .toArray()


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      user:       UserStore.cursor.items.cursor(@props.user_id)
      companies:  CompanyStore.cursor.items


  # Renderers
  #
  render: ->
    <CompanyList companies = { @getCompanies() } />


module.exports = UserCompanies
