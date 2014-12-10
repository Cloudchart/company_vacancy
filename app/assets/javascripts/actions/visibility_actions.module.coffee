# Imports
#
Dispatcher = require('dispatcher/dispatcher')
SyncAPI = require('sync/visibility_sync_api')
ActionFactory = require('actions/factory')

CrudActions = ActionFactory.create 'visibility',
  'create': (id, attributes) -> SyncAPI.create(attributes.owner_id, attributes)
  'update': (id, attributes) -> SyncAPI.update(id, attributes)

CustomActions = {}

# Exports
# 
module.exports = _.extend CustomActions, CrudActions
