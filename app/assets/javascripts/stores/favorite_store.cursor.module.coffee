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

  filterUserFavorites: (user_id, favoritable_type=null) ->
    @byFK('user', user_id).filter (favorite) ->
      !favoritable_type || favorite.get('favoritable_type') == favoritable_type

  filterUserFavoritePinboards: (user_id) ->
    pinboards_ids = @filterUserFavorites(user_id, 'Pinboard')
      .map (item) -> item.get('favoritable_id')

    require('stores/pinboard_store').filter (item) ->
      pinboards_ids.contains(item.get('uuid'))