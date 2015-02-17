# Imports
#

Dispatcher      = require('dispatcher/dispatcher')
GlobalState     = require('global_state/state')

# Exports
#
module.exports = GlobalState.createStore

  displayName:    'CompanyStore'

  collectionName: 'companies'
  instanceName:   'company'

  syncAPI:        require('sync/company')

  search: (query) ->
    @syncAPI.search(query).done (json) =>
      @cursor.items.clear()
      @fetchDone(json)
