# @cjsx React.DOM

GlobalState       = require('global_state/state')

CompanyStore      = require('stores/company_store.cursor')
TokenStore        = require('stores/token_store.cursor')
FavoriteStore     = require('stores/favorite_store.cursor')
RoleStore         = require('stores/role_store.cursor')

CompanyPreview    = require('components/company/preview')
Field             = require('components/form/field')


CompaniesApp = React.createClass

  displayName: 'CompaniesApp'

  mixins: [GlobalState.mixin]


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

  getInitialState: ->
    _.extend @getStateFromStores(), 
      query:    @props.query || location.hash.substr(1) || ''

  getStateFromStores: ->
    myCompanies = CompanyStore.filterForCurrentUser()

    myCompanies:          @sortCompanies(myCompanies)
    searchedCompaniesIds: @getIds(@props.cursor.companies).filter((companyId) => !@getIds(myCompanies).contains(companyId))

  onGlobalStateChange: ->
    @setState  @getStateFromStores()


  # Helpers
  #
  filterByName: (companies) ->
    companies.filter((company) => (company.get('name') || "").toLowerCase().indexOf(@state.query.toLowerCase()) != -1)

  getIds: (companies) ->
    companies.map((company) -> company.get('uuid')).toSeq()

  getMyCompaniesIds: ->
    @getIds(@filterByName(@state.myCompanies))

  sortCompanies: (companies) ->
    companies.sortBy (company) ->
      id = company.get('uuid')

      -2 * (+RoleStore.filterForCompanies().map((role) -> role.get('owner_id')).contains(id)) -
      (+TokenStore.filterCompanyInvites().map((token) -> token.get('owner_id')).contains(id))

  search: (query) ->
    @clearSearchedCompanies()
    CompanyStore.search(query)

  clearSearchedCompanies: ->
    @props.cursor.companies.transaction =>
      @props.cursor.companies.forEach (item, id) =>
        if @state.searchedCompaniesIds.has(id)
          @props.cursor.companies.removeIn(id)

  updateStores: ->
    @props.cursor.companies.transaction =>
      @props.cursor.tokens.clear()
      @props.cursor.favorites.clear()

    CompanyStore.fetchAll().done =>
      @search(@state.query)


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


  # Renderers
  #
  renderSearch: ->
    <div className="search">
      <Field 
        placeholder = "Search"
        onChange    = { @handleChange }
        value       = { @state.query }
      />
    </div>

  renderCompanyPreview: (companyId) ->
    <section key={companyId} className="cloud-column">
      <CompanyPreview 
        key        = { companyId }
        onSyncDone = { @updateStores }
        uuid       = { companyId } />
    </section>

  renderAddCompany: ->
    <section key="add" className="cloud-column">
      <article className="company-add cloud-card">
        <a href="companies/new">
          <i className="fa fa-plus"></i>
          <span className="hint">Create company</span>
        </a>
      </article>
    </section>

  renderCompanyCollection: (ids) ->
    ids.toArray().map (id) => @renderCompanyPreview(id)

  renderCompanies: ->
    @renderCompanyCollection(@getMyCompaniesIds())
      .concat(@renderAddCompany())
      .concat(@renderCompanyCollection(@state.searchedCompaniesIds))


  render: ->
    <section className="cloud-profile-companies">
      { @renderSearch() }
      <section className="companies-list cloud-columns cloud-columns-flex">
        { @renderCompanies() }
      </section>
    </section>


module.exports = CompaniesApp
