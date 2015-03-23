Dispatcher  = require('dispatcher/dispatcher')
GlobalState = require('global_state/state')


module.exports = GlobalState.createStore

  displayName:    'FavoriteStore'

  collectionName: 'favorites'
  instanceName:   'favorite'

  findByCompany: (company_id) ->
    @findByFavoritable(company_id, 'Company')

  findByUser: (user_id) ->
    @findByFavoritable(user_id, 'User')

  findByFavoritable: (favoritable_id, favoritable_type) ->
    @filter (favorite) => 
      favorite.get('favoritable_id') == favoritable_id &&
      favorite.get('favoritable_type') == favoritable_type
    .first()