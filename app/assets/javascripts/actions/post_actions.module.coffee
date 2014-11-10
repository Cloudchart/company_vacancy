# Imports
#
SyncAPI = require('sync/post_sync_api')
BlockableActions = require('actions/mixins/blockable_actions')
FactoryActions = require('actions/mixins/factory_actions')

CustomActions = {}

CrudActions = FactoryActions.create 'post',
  'create': (id, attributes) -> SyncAPI.create(attributes.owner_id, attributes)
  'update': 'default'
  'destroy': 'default'

# Exports
# 
Actions = _.merge CustomActions, CrudActions
Actions = _.merge Actions, BlockableActions

module.exports = Actions
