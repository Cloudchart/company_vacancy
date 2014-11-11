# Imports
#
SyncAPI = require('sync/post_sync_api')
BlockableActions = require('actions/mixins/blockable_actions')
ActionFactory = require('actions/factory')

CustomActions = {}

CrudActions = ActionFactory.create 'post',
  'create': (id, attributes) -> SyncAPI.create(attributes.owner_id, attributes)
  'update': (id, attributes) -> SyncAPI.update(id, attributes)
  'delete': (id) -> SyncAPI.delete(id)

# Exports
# 
Actions = _.merge CustomActions, CrudActions
Actions = _.merge Actions, BlockableActions

module.exports = Actions
