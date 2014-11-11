# Imports
#
CloudFlux = require('cloud_flux')

CallbackFactory = require('stores/callback_factory')


CrudCallbacks = CallbackFactory.create 'post', ['create', 'update', 'destroy']

DefaultMethods = 

  getSchema: ->
    uuid: ''
    title: ''
    cover_uid: null
    published_at: null
    owner_type: ''
    owner_id: ''


# Exports
#
module.exports = CloudFlux.createStore _.extend(DefaultMethods, CrudCallbacks)
