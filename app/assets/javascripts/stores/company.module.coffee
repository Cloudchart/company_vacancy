# Imports
#
CloudFlux         = require('cloud_flux')
Constants         = require('constants')

# Exports
#
module.exports = CloudFlux.createStore

  onAccessRightsFetchDone: ->
    @store.emitChange()

  onUpdate: (key, attributes, token) ->
    @store.start_sync(key, token)
    @store.update(key, attributes)
    @store.emitChange()
  
  onUpdateDone: (key, json, token) ->
    @store.stop_sync(key, token)
    @store.update(key, json)
    # @store.commit(key)
    @store.emitChange()
  
  onUpdateFail: (key, json, xhr, token) ->
    @store.stop_sync(key, token)
    # @store.undo(key)
    @store.emitChange()
  
  # onCompanyAcceptInvite: (key, sync_token) ->
  #   @store.start_sync(key, sync_token)
  #   @store.emitChange()
  #   console.log 'onCompanyAcceptInvite'

  # onCompanyAcceptInviteDone: ->
  #   console.log 'onCompanyAcceptInviteDone'
  
  # onCompanyAcceptInviteFail: ->
  #   console.log 'onCompanyAcceptInviteFail'

  getSchema: ->
    uuid:         ''
    name:         ''
    description:  ''
    logotype_url: null
    is_read_only: true
    can_follow:   false
    is_followed:  false
    meta:         {}
    flags:        {}

  getActions: ->
    actions = {}

    actions['company:access_rights:fetch:done'] = @onAccessRightsFetchDone

    actions[Constants.Company.UPDATE]       = @onUpdate
    actions[Constants.Company.UPDATE_DONE]  = @onUpdateDone
    actions[Constants.Company.UPDATE_FAIL]  = @onUpdateFail

    actions[Constants.Company.FOLLOW]       = @onUpdate
    actions[Constants.Company.FOLLOW_DONE]  = @onUpdateDone
    actions[Constants.Company.FOLLOW_FAIL]  = @onUpdateFail

    actions[Constants.Company.UNFOLLOW]       = @onUpdate
    actions[Constants.Company.UNFOLLOW_DONE]  = @onUpdateDone
    actions[Constants.Company.UNFOLLOW_FAIL]  = @onUpdateFail

    actions
