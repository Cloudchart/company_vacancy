# Imports
#
CloudFlux = require('cloud_flux')
CallbackFactory = require('stores/callback_factory')


CrudActions = ['create', 'update', 'destroy']
CrudCallbacks = CallbackFactory.create 'person', CrudActions


DefaultMethods = 

  getSchema: ->
    uuid:         null
    company_id:   ''
    full_name:    ''
    first_name:   ''
    last_name:    ''
    email:        ''
    occupation:   ''
    avatar_url:   ''
    hired_on:     ''
    fired_on:     ''

  getActions: ->
    actions = {}

    _.each CrudActions, (action) => 
      actions["person:#{action}-"] = @["handle#{_.str.titleize(action)}"]
      actions["person:#{action}-:done"] = @["handle#{_.str.titleize(action)}Done"]
      actions["person:#{action}-:fail"] = @["handle#{_.str.titleize(action)}Fail"]

    # other actions goes here

    actions


# Exports
#
module.exports = CloudFlux.createStore _.extend(DefaultMethods, CrudCallbacks)
