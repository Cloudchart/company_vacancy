# Imports
#
CloudFlux = require('cloud_flux')
CallbackFactory = require('stores/callback_factory')


CrudActions = ['create', 'update', 'destroy']
CrudCallbacks = CallbackFactory.create 'post', CrudActions


DefaultMethods =
  
  
  handleFetchOneDone: (id, json) ->
    @store.add_or_update(json.post.uuid, json.post)
    @store.emitChange()
  
  
  getSchema: ->
    uuid:           ''
    title:          ''
    effective_from: ''
    effective_till: ''
    owner_type:     ''
    owner_id:       ''
    tag_names:      []
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
    actions['post:fetch-one:done'] = @handleFetchOneDone

    actions
  

# Exports
#
module.exports = CloudFlux.createStore _.extend(DefaultMethods, CrudCallbacks)
