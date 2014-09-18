# Imports
#
CloudFlux = require('cloud_flux')


# Exports
#
module.exports = CloudFlux.createStore


  onAccessRightsFetchDone: (key, json) ->
    _.each (json.roles), (props) => @store.add_or_update(props.uuid, props)
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
    @store.emitChange()
  

  getActions: ->
    'company:access_rights:fetch:done': @onAccessRightsFetchDone

    'role:revoke':       @onRevoke
    'role:revoke:done':  @onRevokeDone
    'role:revoke:fail':  @onRevokeFail
