# Imports
#
Dispatcher = require('dispatcher/dispatcher')
SyncAPI = require('sync/post_sync_api')
BlockableActions = require('actions/mixins/blockable_actions')
ActionFactory = require('actions/factory')

CrudActions = ActionFactory.create 'post',
  'create': (id, attributes) -> SyncAPI.create(attributes.owner_id, attributes)
  'update': (id, attributes) -> SyncAPI.update(id, attributes)
  'destroy': (id) -> SyncAPI.destroy(id)

CustomActions = {}

# Exports
# 
Actions = _.extend CustomActions, CrudActions
Actions = _.extend Actions, BlockableActions

module.exports = Actions
