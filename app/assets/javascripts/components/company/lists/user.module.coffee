# @cjsx React.DOM

GlobalState      = require('global_state/state')

CompanyStore     = require('stores/company_store.cursor')

RoleStore        = require('stores/role_store.cursor')

CompanyList      = require('components/company/list')
CompanyPreview   = require('components/company/preview')


UserCompanies = React.createClass

  displayName: 'CompanyList'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      companies: ->
        """
          User {
            roles,
            owned_companies {
              #{CompanyPreview.getQuery('company')}
            }
          }
        """

    isEmpty: (user_id) ->
      !CompanyStore.filterForUser(user_id).size


  # Component specifications
  #
  propTypes:
    user_id: React.PropTypes.string.isRequired

  getDefaultProps: ->
    cursor:
      roles: RoleStore.cursor.items


  # Helpers
  #
  isLoaded: ->
    @cursor.companies.deref(false)

  getCompanies: ->
    CompanyStore
      .filterForUser(@props.user_id)
      .sortBy (company) -> company.get('name')
      .toArray()


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      companies: CompanyStore.cursor.items


  # Renderers
  #
  render: ->
    return null unless @isLoaded()

    <CompanyList companies = { @getCompanies() } />


module.exports = UserCompanies