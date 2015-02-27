Dispatcher  = require('dispatcher/dispatcher')
GlobalState = require('global_state/state')


module.exports = GlobalState.createStore

  displayName:    'FavoriteStore'

  collectionName: 'favorites'
  instanceName:   'favorite'

  findByCompany: (company) ->
    @cursor.items.filter((favorite) => favorite.get('favoritable_id') == company.get('uuid')).first()