# Imports
#
CloudFlux         = require('cloud_flux')
Constants         = require('constants')
Dispatcher        = require('dispatcher/dispatcher')
GlobalState       = require('global_state/state')

# Cursor Meta Store
#
EmptyData                 = Immutable.Map()

CompanyMetaCursor         = GlobalState.cursor(['stores', 'companies', 'meta'])
CompanyFlagsCursor        = GlobalState.cursor(['stores', 'companies', 'flags'])

Dispatcher.register (payload) ->

  switch payload.action.type


    # when 'post:fetch-one:done'
    #   [post_id, json] = payload.action.data
    #   if json.post.owner_type == 'Company' and json.owner
    #     CompanyMetaCursor.set(json.owner.uuid, json.owner.meta)
    #     CompanyFlagsCursor.set(json.owner.uuid, json.owner.flags)


    when 'company:fetch:done'
      [company_id, json] = payload.action.data

      CompanyMetaCursor.set(company_id, json.company.meta)
      CompanyFlagsCursor.set(company_id, json.company.flags)


    when 'company:fetch:many:done'
      [{companies}] = payload.action.data

      Immutable.Seq(companies).forEach (company) ->
        CompanyMetaCursor.set(company.uuid, company.meta)
        CompanyFlagsCursor.set(company.uuid, company.flags)


    when Constants.Company.VERIFY_SITE_URL_DONE, Constants.Company.UPDATE_DONE, Constants.Company.FOLLOW_DONE, Constants.Company.UNFOLLOW_DONE
      [company_id, json] = payload.action.data

      CompanyMetaCursor.set(company_id, Immutable.fromJS(json.meta))
      CompanyFlagsCursor.set(company_id, Immutable.fromJS(json.flags))


    when 'company:access_rights:fetch:done'
      [company_id, json] = payload.action.data

      GlobalState.cursor().setIn(['constants', 'companies', 'invitable_roles'], json.invitable_roles)
      GlobalState.cursor().setIn(['constants', 'companies', 'invitable_contacts'], json.invitable_contacts)
      GlobalState.cursor().setIn(['flags', 'companies', 'isAccessRightsLoaded'], true)


# Exports
#
module.exports = CloudFlux.createStore


  # onPostFetchOneDone: (post_id, json) ->
  #   if json.post.owner_type == 'Company' and json.owner
  #     @store.add_or_update(json.owner.uuid, json.owner)
  #     @store.emitChange()


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
    uuid:            ''
    name:            ''
    description:     ''
    is_published:    false
    established_on:  ''
    site_url:        ''
    slug:            ''
    logotype_url:    null
    company_url:     null
    url:             null
    is_name_in_logo: false
    tag_names:       []
    post_ids:        []
    facebook_share_url: ''
    twitter_share_url: ''


  getActions: ->
    actions = {}

    # actions['post:fetch-one:done'] = @onPostFetchOneDone

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
