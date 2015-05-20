Dispatcher  = require('dispatcher/dispatcher')
GlobalState = require('global_state/state')


module.exports = GlobalState.createStore

  displayName:    'FavoriteStore'

  collectionName: 'favorites'
  instanceName:   'favorite'

  foreignKeys:
    'user':
      fields: 'user_id'

    'favoritable':
      fields: ['favoritable_id', 'favoritable_type']

  findByCompanyForUser: (company_id, follower_id) ->
    @findByFavoritableAndFollower(company_id, 'Company', follower_id)

  findByUserForUser: (user_id, follower_id) ->
    @findByFavoritableAndFollower(user_id, 'User', follower_id)

  findByPinboardForUser: (pinboard_id, follower_id) ->
    @findByFavoritableAndFollower(pinboard_id, 'Pinboard', follower_id)

  findByFavoritableAndFollower: (id, type, follower_id) ->
    @byFK('favoritable', id, type).filter (favorite) ->
      favorite.get('user_id') == follower_id
    .first()