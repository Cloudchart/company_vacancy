# Imports
#
Dispatcher = require('dispatcher/dispatcher')
SyncAPI = require('sync/post_sync_api')
BlockableActions = require('actions/mixins/blockable_actions')
ActionFactory = require('actions/factory')

CrudActions = ActionFactory.create 'post',
  # 'create': (id, attributes) -> SyncAPI.create(attributes.owner_id, attributes)
  'update': (id, attributes) -> SyncAPI.update(id, attributes)
  'destroy': (id) -> SyncAPI.destroy(id)

CustomActions =

  create: (id, attributes, sync_token = 'create') ->
    Dispatcher.handleClientAction
      type: 'post:create'
      data: [id, attributes, sync_token]

    done = (json) ->
      Dispatcher.handleServerAction
        type: 'post:create:done'
        data: [id, attributes, json, sync_token]

      Dispatcher.handleServerAction
        type: 'modal:show:post'
        data: [json.uuid, json.owner_id]

    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: 'post:create:fail'
        data: [id, attributes, xhr.responseJSON, xhr, sync_token]

    SyncAPI.create(attributes.owner_id, attributes, done, fail)


# Exports
# 
Actions = _.extend CustomActions, CrudActions
Actions = _.extend Actions, BlockableActions

module.exports = Actions
