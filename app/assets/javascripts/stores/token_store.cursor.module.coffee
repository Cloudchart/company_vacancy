Dispatcher  = require('dispatcher/dispatcher')
GlobalState = require('global_state/state')


module.exports = GlobalState.createStore

  displayName:    'TokenStore'

  collectionName: 'tokens'
  instanceName:   'token'

  filterInvites: (type) ->
    @cursor.items.filter (token) ->
      token.get('owner_type') == type && 
      token.get('name') == 'invite'

  filterCompanyInvites: (user) ->
    @filterInvites('Company')

  findCompanyInvite: (company) ->
    @filterCompanyInvites().
      filter((token) => token.get('owner_id') == company.get('uuid')).first()