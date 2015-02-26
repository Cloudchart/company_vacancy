# @cjsx React.DOM

GlobalState       = require('global_state/state')

CompanyStore      = require('stores/company_store.cursor')
TokenStore        = require('stores/token_store.cursor')
FavoriteStore     = require('stores/favorite_store.cursor')
RoleStore         = require('stores/role_store.cursor')

CompanyList       = require('components/company/list')
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
    myCompaniesIds:        @getIds(CompanyStore.getMyCompanies())
    invitedCompaniesIds:   @getIds(CompanyStore.getInvitedCompanies())
    favoritedCompaniesIds: @getIds(CompanyStore.getFavoritedCompanies())
    searchedCompaniesIds:  CompanyStore.getSearchedCompanies().map((company) -> company.get('uuid')).toSeq()

  onGlobalStateChange: ->
    @setState  @getStateFromStores()


  # Helpers
  #
  getIds: (companies) ->
    companies
      .filter((company) => company.get('name').toLowerCase().indexOf(@state.query.toLowerCase()) != -1)
      .map((company) -> company.get('uuid')).toSeq()

  search: (query) ->
    if query.length > 2
      location.hash = "#{@state.query}"
      CompanyStore.search(query)
    else if query.length == 0
      location.hash = ""
      CompanyStore.search(query)

  updateStores: ->
    CompanyStore.fetchAll().done =>
      @search(@state.query)


  # Handlers
  #
  handleChange: (event) ->
    @setState(query: event.target.value)

    clearTimeout(@timeout)
    @timeout = setTimeout =>
      @search(@state.query)
    , 250

  handleSyncDone: ->
    @updateStores()


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

  renderCompanies: (companiesIds, headerText='') ->
    <CompanyList 
      companiesIds = { companiesIds }
      headerText   = { headerText}
      onSyncDone   = { @handleSyncDone } />

  renderMyCompanies: ->
    @renderCompanies(@state.myCompaniesIds, 'My Companies')

  renderInvitedCompanies: ->
    @renderCompanies(@state.invitedCompaniesIds, 'Invited Companies')

  renderFavoritedCompanies: ->
    @renderCompanies(@state.favoritedCompaniesIds, 'Followed Companies')

  renderSearchedCompanies: ->
    @renderCompanies(@state.searchedCompaniesIds)


  render: ->
    <section className="cloud-profile-companies">
      { @renderSearch() }
      { @renderMyCompanies() }
      { @renderInvitedCompanies() }
      { @renderFavoritedCompanies() }
      { @renderSearchedCompanies() }
    </section>


module.exports = CompaniesApp
