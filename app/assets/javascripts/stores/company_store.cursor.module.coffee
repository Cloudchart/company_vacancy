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
    @syncAPI.search(query).done (json) =>
      @cursor.items.transaction =>
        @cursor.items.forEach (item, id) =>
          if @getSearchedCompanies().map((company) -> company.get('uuid')).has(id)
            @cursor.items.removeIn(item.get('uuid'))
        Dispatcher.handleServerAction
          type: 'fetch:done'
          data: [json]


  # temp solution, will go away
  fetchAll: ->
    promise = @syncAPI.fetchAll()

    promise.done (json) =>
      @cursor.items.transaction =>
        @cursor.items.forEach (item, id) =>
          if !@getSearchedCompanies().map((company) -> company.get('uuid')).has(id)
            @cursor.items.removeIn(item.get('uuid'))
        TokenStore.cursor.items.clear()
        RoleStore.cursor.items.clear()
        FavoriteStore.cursor.items.clear()
        Dispatcher.handleServerAction
          type: 'fetch:done'
          data: [json]

    promise


  getMyCompanies: ->
    companiesIds = RoleStore.cursor.items.map((role) -> role.get('owner_id'))

    @cursor.items.filter (company) -> companiesIds.contains(company.get('uuid'))

  getInvitedCompanies: ->
    companiesIds = TokenStore.cursor.items.map (token) -> token.get('owner_id') 

    @cursor.items.filter (company) -> companiesIds.contains(company.get('uuid'))

  getFavoritedCompanies: ->
    companiesIds = FavoriteStore.cursor.items.map (favorite) -> token.get('favoritable_id') 

    @cursor.items.filter (company) -> companiesIds.contains(company.get('uuid'))

  getSearchedCompanies: ->
    @cursor.items.filter (company) =>
      !@getMyCompanies().map((company) -> company.get('uuid')).toSeq().contains(company.get('uuid')) && 
      !@getInvitedCompanies().map((company) -> company.get('uuid')).toSeq().contains(company.get('uuid')) &&
      !@getFavoritedCompanies().map((company) -> company.get('uuid')).toSeq().contains(company.get('uuid'))

