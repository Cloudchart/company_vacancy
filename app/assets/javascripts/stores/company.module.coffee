# Imports
#
CloudFlux         = require('cloud_flux')
Constants         = require('constants')

# Exports
#
module.exports = CloudFlux.createStore

  onAccessRightsFetchDone: ->
    @store.emitChange()

  onVerifySiteUrl: (key, token) ->
    @store.start_sync(key, token)
    @store.emitChange()

  onVerifySiteUrlDone: (key, json, token) ->
    @store.stop_sync(key, token)

    if json == "ok"
      flags = _.extend(@store.get(key).flags, { is_site_url_verified: true })
      @store.update(key, { flags: flags })

    @store.emitChange()

  onVerifySiteUrlFail: (key, json, token) ->
    @store.stop_sync(key, token)
    @store.emitChange()

  onUpdate: (key, attributes, token) ->
    @store.start_sync(key, token)
    if token != 'publish' && token != 'site_url'
      @store.update(key, attributes)

    @store.emitChange()
  
  onUpdateDone: (key, json, token) ->
    @store.stop_sync(key, token)
    @store.update(key, json)
    @store.commit(key)
    @store.emitChange()
  
  onUpdateFail: (key, json, xhr, token) ->
    @store.stop_sync(key, token)
    @store.rollback(key)
    @store.emitChange()
  
  onRoleCreateDone: (key, json, sync_token) ->
    if sync_token == 'accept_invite' and json.company
      @store.update(json.company.uuid, json.company)
      @store.emitChange()
  
  getSchema: ->
    uuid:           ''
    name:           ''
    description:    ''
    is_published:   false
    established_on: ''
    site_url:       ''
    slug:           ''
    meta: {}
    flags: {}

  getActions: ->
    actions = {}

    actions['company:access_rights:fetch:done'] = @onAccessRightsFetchDone

    actions[Constants.Company.VERIFY_SITE_URL]      = @onVerifySiteUrl
    actions[Constants.Company.VERIFY_SITE_URL_DONE] = @onVerifySiteUrlDone
    actions[Constants.Company.VERIFY_SITE_URL_FAIL] = @onVerifySiteUrlFail

    actions[Constants.Company.UPDATE]       = @onUpdate
    actions[Constants.Company.UPDATE_DONE]  = @onUpdateDone
    actions[Constants.Company.UPDATE_FAIL]  = @onUpdateFail

    actions[Constants.Company.FOLLOW]       = @onUpdate
    actions[Constants.Company.FOLLOW_DONE]  = @onUpdateDone
    actions[Constants.Company.FOLLOW_FAIL]  = @onUpdateFail

    actions[Constants.Company.UNFOLLOW]       = @onUpdate
    actions[Constants.Company.UNFOLLOW_DONE]  = @onUpdateDone
    actions[Constants.Company.UNFOLLOW_FAIL]  = @onUpdateFail

    actions[Constants.Role.CREATE_DONE]  = @onRoleCreateDone

    actions
