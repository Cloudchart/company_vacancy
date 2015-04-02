# @cjsx React.DOM

GlobalState       = require('global_state/state')

CompanyStore      = require('stores/company_store.cursor')
TokenStore        = require('stores/token_store.cursor')
FavoriteStore     = require('stores/favorite_store.cursor')
RoleStore         = require('stores/role_store.cursor')
UserStore         = require('stores/user_store.cursor')

CompanyList       = require('components/company/list')
Field             = require('components/form/field')


CompaniesApp = React.createClass

  displayName: 'CompaniesApp'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:
      viewer: ->
        """
          Viewer {
            system_roles
          }
        """


  # Component specifications
  #
  propTypes:
    query: React.PropTypes.string

  getDefaultProps: ->
    cursor:
      companies: CompanyStore.cursor.items
      tokens:    TokenStore.cursor.items
      favorites: FavoriteStore.cursor.items
      roles:     RoleStore.cursor.items
      user:      UserStore.me()

  getInitialState: ->
    _.extend @getStateFromStores(),
      query:    @props.query || location.hash.substr(1) || ''

  getStateFromStores: ->
    myCompanies = CompanyStore.filterForCurrentUser()

    myCompanies:          @sortCompanies(myCompanies)
    searchedCompaniesIds: @getIds(@props.cursor.companies).filter((companyId) => !@getIds(myCompanies).contains(companyId))

  onGlobalStateChange: ->
    @setState  @getStateFromStores()

  fetchViewer: ->
    GlobalState.fetch(@getQuery('viewer'))


  # Helpers
  #
  isCurrentUserSystemEditor: ->
    RoleStore.rolesFor(@props.cursor.user.get('uuid'))
      .find (role) =>
        role.get('owner_id',    null)   is null     and
        role.get('owner_type',  null)   is null     and
        role.get('value')               is 'editor'

  filterByName: (companies) ->
    companies.filter((company) => (company.get('name') || "").toLowerCase().indexOf(@state.query.toLowerCase()) != -1)

  getIds: (companies) ->
    companies.map((company) -> company.get('uuid')).toSeq()

  getMyCompaniesIds: ->
    @getIds(@filterByName(@state.myCompanies))

  getAllIds: ->
    @getMyCompaniesIds().concat(@state.searchedCompaniesIds)

  sortCompanies: (companies) ->
    companies.sortBy (company) ->
      id = company.get('uuid')

      -2 * (+RoleStore.filterForCompanies().map((role) -> role.get('owner_id')).contains(id)) -
      (+TokenStore.filterCompanyInvites().map((token) -> token.get('owner_id')).contains(id))

  search: (query) ->
    @clearSearchedCompanies()
    CompanyStore.search(query)

  clearSearchedCompanies: ->
    @props.cursor.companies.forEach (item, id) =>
      if @state.searchedCompaniesIds.has(id)
        @props.cursor.companies.removeIn(id)

  updateStores: ->
    @props.cursor.tokens.clear()
    @props.cursor.favorites.clear()

    CompanyStore.fetchAll().done =>
      @search()

  # Handlers
  #
  handleChange: (event) ->
    query = event.target.value
    @setState(query: query)

    if query.length > 2 || query.length == 0
      clearTimeout(@timeout)
      @timeout = setTimeout =>
        location.hash = "#{@state.query}"
        @search(@state.query)
      , 250

  # Lifecycle methods
  #
  componentWillMount: ->
    @updateStores()
    @fetchViewer()


  # Renderers
  #
  renderSearch: ->
    return null

    <div className="search">
      <Field
        placeholder = "Search"
        onChange    = { @handleChange }
        value       = { @state.query }
      />
    </div>

  renderAddButton: ->
    return null unless @isCurrentUserSystemEditor()

    <div className="company-add button green">
      <a href="companies/new">
        <i className="fa fa-plus"></i>
        <span>Create company</span>
      </a>
    </div>

  renderHeader: ->
    return null unless @isCurrentUserSystemEditor()

    <header className="cloud-columns cloud-columns-flex">
      { @renderSearch() }
      { @renderAddButton() }
    </header>


  render: ->
    <section className="cloud-profile-companies">
      { @renderHeader() }
      <CompanyList
        ids            = { @getAllIds() }
        isInLegacyMode = { true }
        onSyncDone     = { @updateStores } />
    </section>


module.exports = CompaniesApp
