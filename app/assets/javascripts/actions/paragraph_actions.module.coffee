# Imports
#
Dispatcher        = require('dispatcher/dispatcher')
SyncAPI  = require('sync/paragraph_sync_api')
ActionFactory = require('actions/factory')

CrudActions = ActionFactory.create 'paragraph',
  'create': (key, attributes) -> SyncAPI.create(attributes.owner_id, attributes)
  'update': (key, block_id, attributes) -> SyncAPI.update(block_id, attributes)
  'destroy': (key, block_id) -> SyncAPI.destroy(block_id)

CustomActions = {}

# Exports
#
module.exports = _.extend CustomActions, CrudActions
