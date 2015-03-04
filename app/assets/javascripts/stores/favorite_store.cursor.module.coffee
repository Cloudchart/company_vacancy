Dispatcher  = require('dispatcher/dispatcher')
GlobalState = require('global_state/state')


module.exports = GlobalState.createStore

  displayName:    'FavoriteStore'

  collectionName: 'favorites'
  instanceName:   'favorite'

  findByCompany: (company_id) ->
    @cursor.items.filter((favorite) => favorite.get('favoritable_id') == company_id).first()