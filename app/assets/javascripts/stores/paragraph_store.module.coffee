# Imports
#
CloudFlux = require('cloud_flux')
CallbackFactory = require('stores/callback_factory')

CrudActions = ['create', 'update', 'destroy']
CrudCallbacks = CallbackFactory.create 'paragraph', CrudActions

DefaultMethods = 

  getSchema: ->
    uuid: ''
    owner_type: ''
    owner_id: ''
    content: ''

  getActions: ->
    actions = {}

    _.each CrudActions, (action) => 
      actions["paragraph:#{action}"] = @["handle#{_.str.titleize(action)}"]
      actions["paragraph:#{action}:done"] = @["handle#{_.str.titleize(action)}Done"]
      actions["paragraph:#{action}:fail"] = @["handle#{_.str.titleize(action)}Fail"]

    # other actions goes here

    actions


# Exports
#
module.exports = CloudFlux.createStore _.extend(DefaultMethods, CrudCallbacks)
