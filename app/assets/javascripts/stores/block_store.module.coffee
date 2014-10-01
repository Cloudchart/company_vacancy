# Imports
#
CloudFlux         = require('cloud_flux')
Constants         = require('constants')

# Exports
#
module.exports = CloudFlux.createStore


  onUpdate: (key, attributes, token) ->
    @store.update(key, attributes)
    @store.emitChange()


  getActions: ->
    actions = {}
    
    actions['block:update'] = @onUpdate
    
    actions


  getSchema: ->
    uuid:           ''
    identity_type:  ''
    identity_ids:   []
    owner_type:     ''
    owner_id:       ''
    title:          ''
    section:        ''
    is_locked:      false
    position:       0
