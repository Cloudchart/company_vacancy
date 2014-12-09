# Imports
#
CloudFlux = require('cloud_flux')
CallbackFactory = require('stores/callback_factory')

model_name = 'visibility'
CrudActions = ['create', 'update', 'destroy']

CrudCallbacks = CallbackFactory.create model_name, CrudActions


DefaultMethods = 

  getSchema: ->
    uuid: ''
    value: ''
    event_name: ''
    owner_id: ''
    owner_type: ''
    created_at: ''
    updated_at: ''

  getActions: ->
    actions = {}

    _.each CrudActions, (action) => 
      actions["#{model_name}:#{action}"] = @["handle#{_.str.titleize(action)}"]
      actions["#{model_name}:#{action}:done"] = @["handle#{_.str.titleize(action)}Done"]
      actions["#{model_name}:#{action}:fail"] = @["handle#{_.str.titleize(action)}Fail"]

    # other actions goes here

    actions
    

# Exports
#
module.exports = CloudFlux.createStore _.extend(DefaultMethods, CrudCallbacks)
