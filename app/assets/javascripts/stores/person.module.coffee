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


  onCreateDone: (key, attributes, json, token) ->
    @store.stop_sync(key, token)
    @store.reset(key)

    attributes = json.person || json

    @store.add(attributes.uuid, attributes)
    @store.emitChange()


  onCreateFail: (key, attributes, json, xhr, token) ->
    @store.stop_sync(key, token)
    @store.add_errors(key, json.person.errors) if json and json.person and json.person.errors
    @store.emitChange()
  
  
  onUpdate: (key, attributes, token) ->
    @store.start_sync(key, token)
    @store.update(key, attributes)
    @store.emitChange()
  
  
  onUpdateDone: (key, attributes, json, token) ->
    @store.stop_sync(key, token)
    @store.update(key, json.person || json)
    @store.commit()
    @store.emitChange()
  
  
  onUpdateFail: ->
    @store.stop_sync(key, token)
    @store.undo()
    @store.emitChange()


  getActions: ->
    'person:create-':       @onCreate
    'person:create-:done':  @onCreateDone
    'person:create-:fail':  @onCreateFail
    
    'person:update-':       @onUpdate
    'person:update-:done':  @onUpdateDone
    'person:update-:fail':  @onUpdateFail


  getSchema: ->
    uuid:         null
    company_id:   ''
    full_name:    ''
    first_name:   ''
    last_name:    ''
    email:        ''
    occupation:   ''
    avatar_url:   ''
