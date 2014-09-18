# Imports
#
CloudFlux = require('cloud_flux')


# Exports
#
module.exports = CloudFlux.createStore


  onAccessRightsFetchDone: (key, json) ->
    _.each (json.access_rights), (props) => @store.add_or_update(props.uuid, props)
    
    @store.emitChange()
  
  
  onRevoke: (key) ->
    @store.start_sync(key, 'revoke')
    @store.emitChange()
  
  
  onRevokeDone: (key) ->
    @store.stop_sync(key, 'revoke')
    @store.remove(key)
    @store.emitChange()
  
  
  onRevokeFail: (key) ->
    @store.stop_sync(key, 'revoke')
    #@store.set_errors(key, { 'base': 'server' })
    @store.emitChange()
  

  getActions: ->
    'company:access_rights:fetch:done': @onAccessRightsFetchDone

    'access_rights:revoke':       @onRevoke
    'access_rights:revoke:done':  @onRevokeDone
    'access_rights:revoke:fail':  @onRevokeFail
