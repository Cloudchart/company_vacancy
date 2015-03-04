Dispatcher    = require('dispatcher/dispatcher')
GlobalState   = require('global_state/state')

RoleStore     = require('stores/role_store.cursor')
TokenStore    = require('stores/token_store.cursor')
FavoriteStore = require('stores/favorite_store.cursor')


module.exports = GlobalState.createStore

  displayName:    'CompanyStore'

  collectionName: 'companies'
  instanceName:   'company'

  syncAPI:        require('sync/company')

  search: (query) ->
    @syncAPI.search(query).done @fetchDone

  filterForUser: (user_id) ->
    companiesRolesIds = RoleStore.filterForUserCompanies(user_id).map((role) -> role.get('owner_id'))

    @cursor.items.filter (company) -> companiesRolesIds.contains(company.get('uuid'))

  filterForCurrentUser: ->
    companiesRolesIds = RoleStore.filterForCompanies().map((role) -> role.get('owner_id'))
    companiesInvitesIds = TokenStore.filterCompanyInvites().map (token) -> token.get('owner_id') 
    companiesFavoritesIds = FavoriteStore.cursor.items.map (favorite) -> favorite.get('favoritable_id') 

    @cursor.items
      .filter (company) -> companiesRolesIds.contains(company.get('uuid'))     ||
                           companiesInvitesIds.contains(company.get('uuid'))   ||
                           companiesFavoritesIds.contains(company.get('uuid'))
