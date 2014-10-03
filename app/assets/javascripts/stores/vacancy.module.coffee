# Imports
#
CloudFlux         = require('cloud_flux')
Constants         = require('constants')

# Exports
#
module.exports = CloudFlux.createStore


  onCreate: (key, attributes, token) ->
    @store.start_sync(key, token)
    @store.update(key, attributes)
    @store.emitChange()
  
  
  onCreateDone: (key, json, token) ->
    @store.stop_sync(key, token)
    @store.reset(key)

    attributes = json.vacancy || json

    @store.add(attributes.uuid, attributes)
    @store.emitChange()
  
  
  onCreateFail: (key, json, xhr, token) ->
    @store.stop_sync(key, token)
    @store.add_errors(key, json.vacancy.errors) if json and json.vacancy and json.vacancy.errors
    @store.emitChange()


  getActions: ->
    'vacancy:create-':       @onCreate
    'vacancy:create:done-':  @onCreateDone
    'vacancy:create:fail-':  @onCreateFail


  getSchema: ->
    uuid:         ''
    company_id:   ''
    name:         ''
    description:  ''
