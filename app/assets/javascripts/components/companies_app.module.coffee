# @cjsx React.DOM

GlobalState       = require('global_state/state')

CompanyStore      = require('stores/company_store.cursor')
TokenStore        = require('stores/token_store.cursor')
FavoriteStore     = require('stores/favorite_store.cursor')
RoleStore         = require('stores/role_store.cursor')

CompanyList       = require('components/company/list')

SearchCursorPath  = require('constants').cursors.search

SearchCursor      = GlobalState.cursor(SearchCursorPath)


CompaniesApp = React.createClass

  displayName: 'CompaniesApp'

  mixins: [GlobalState.mixin]


  # Component specifications
  #
  getDefaultProps: ->
    cursor:
      companies: CompanyStore.cursor.items 
      tokens:    TokenStore.cursor.items
      favorites: FavoriteStore.cursor.items
      roles:     RoleStore.cursor.items
      search:    SearchCursor

  getInitialState: ->
    @getStateFromStores()

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
      .filter((company) => company.get('name').toLowerCase().indexOf(@props.cursor.search.get('query').toLowerCase()) != -1)
      .map((company) -> company.get('uuid')).toSeq()


  # Lifecycle methods
  #
  componentWillMount: ->
    CompanyStore.fetchAll()


  # Renderers
  #
  renderCompanies: (companiesIds, headerText='') ->
    <CompanyList 
      companiesIds = { companiesIds }
      headerText = { headerText} />

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
      { @renderMyCompanies() }
      { @renderInvitedCompanies() }
      { @renderFavoritedCompanies() }
      { @renderSearchedCompanies() }
    </section>


module.exports = CompaniesApp
