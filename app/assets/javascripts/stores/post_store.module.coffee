# Imports
#
CloudFlux = require('cloud_flux')
CallbackFactory = require('stores/callback_factory')


CrudActions = ['create', 'update', 'destroy']
CrudCallbacks = CallbackFactory.create 'post', CrudActions


DefaultMethods = 

  getSchema: ->
    uuid:           ''
    title:          ''
    effective_from: ''
    effective_till: ''
    owner_type:     ''
    owner_id:       ''
    story_ids:      []
    position:       null
    created_at:     ''
    updated_at:     ''

  getActions: ->
    actions = {}

    _.each CrudActions, (action) => 
      actions["post:#{action}"] = @["handle#{_.str.titleize(action)}"]
      actions["post:#{action}:done"] = @["handle#{_.str.titleize(action)}Done"]
      actions["post:#{action}:fail"] = @["handle#{_.str.titleize(action)}Fail"]

    # other actions goes here

    actions
    

# Exports
#
module.exports = CloudFlux.createStore _.extend(DefaultMethods, CrudCallbacks)
