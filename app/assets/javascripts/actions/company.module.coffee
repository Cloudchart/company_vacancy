# Imports
#
Dispatcher    = require('dispatcher/dispatcher')
CompanyStore  = require('stores/company')
TokenStore    = require('stores/token')
SyncAPI       = require('sync/company')
Constants     = require('constants')


handleClientStoreAction = (type, key, attributes, token) ->
  Dispatcher.handleClientAction
    type: [type]
    data: [key, attributes, token]


handleServerStoreDoneAction = (type, key, json, token) ->
  Dispatcher.handleServerAction
    type: type
    data: [key, json, token]


handleServerStoreFailAction = (type, key, xhr, token) ->
  Dispatcher.handleServerAction
    type: type
    data: [key, xhr.responseJSON, xhr, token]


# Exports
#
module.exports =
  
  # 
  # Update
  #
  update: (key, attributes, token = 'update') ->
    handleClientStoreAction(Constants.Company.UPDATE, key, attributes, token)
    
    done = (json) ->
      handleServerStoreDoneAction(Constants.Company.UPDATE_DONE, key, json, token)
  
    fail = (xhr) ->
      handleServerStoreDoneAction(Constants.Company.UPDATE_FAIL, key, xhr, token)
    
    # TODO: should pass an array here
    attributes.tag_names = attributes.tag_names.join(',') if attributes.tag_names
    
    SyncAPI.update(key, attributes, done, fail)
  

  #
  #
  fetchAccessRights: (key, token) ->
    Dispatcher.handleClientAction
      type: 'company:access_rights:fetch'
      data: [key, token]
    

    done = (json) ->
      Dispatcher.handleServerAction
        type: 'company:access_rights:fetch:done'
        data: [key, json, token]
    

    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: 'company:access_rights:fetch:fail'
        data: [key, xhr.responseJSON, xhr, token]
    

    SyncAPI.fetchAccessRights(key, done, fail)


  verifySiteUrl: (key, token = 'verify_site_url') ->
    Dispatcher.handleClientAction
      type: Constants.Company.VERIFY_SITE_URL
      data: [key, token]
    

    done = (json) ->
      Dispatcher.handleServerAction
        type: Constants.Company.VERIFY_SITE_URL_DONE
        data: [key, json, token]
    

    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: Constants.Company.VERIFY_SITE_URL_FAIL
        data: [key, xhr.responseJSON, xhr, token]
    

    SyncAPI.verifySiteUrl(key, done, fail)    
  
  #
  #
  fetchInviteTokens: (key, token) ->
    Dispatcher.handleClientAction
      type: Constants.Company.FETCH_INVITE_TOKENS
      data: [key, token]
    
    done = (json) ->
      Dispatcher.handleServerAction
        type: Constants.Company.FETCH_INVITE_TOKENS_DONE
        data: [key, json, token]
    
    fail = (xhr) ->
      Dispatcher.handleServerAction
        type: Constants.Company.FETCH_INVITE_TOKENS_FAIL
        data: [key, xhr.responseJSON, xhr, token]
    
    SyncAPI.fetchInviteTokens(key, done, fail)

  
  # Follow and Unfollow
  # 
  follow: (key, token = 'follow') ->
    handleClientStoreAction(Constants.Company.FOLLOW, key, null, token)
    
    done = (json) ->
      handleServerStoreDoneAction(Constants.Company.FOLLOW_DONE, key, json, token)
  
    fail = (xhr) ->
      handleServerStoreDoneAction(Constants.Company.FOLLOW_FAIL, key, xhr, token)
    
    SyncAPI.follow(key, done, fail)

  unfollow: (key, token = 'unfollow') ->
    handleClientStoreAction(Constants.Company.UNFOLLOW, key, null, token)
    
    done = (json) ->
      handleServerStoreDoneAction(Constants.Company.UNFOLLOW_DONE, key, json, token)
  
    fail = (xhr) ->
      handleServerStoreDoneAction(Constants.Company.UNFOLLOW_FAIL, key, xhr, token)
    
    SyncAPI.unfollow(key, done, fail)


  # Send invite
  #
  sendInvite: (key, attributes = {}, token = 'send') ->
    handleClientStoreAction(Constants.Token.CREATE, key, attributes, token)
    
    record = TokenStore.get(key)

    done = (json) -> 
      handleServerStoreDoneAction(Constants.Token.CREATE_DONE, key, json, token)
    
    fail = (xhr) ->
      handleServerStoreFailAction(Constants.Token.CREATE_FAIL, key, xhr, token)
    
    SyncAPI.sendInvite(record.owner_id, record.toJSON(), done, fail)


  # Resend invite
  #
  resendInvite: (key, token = 'resend') ->
    handleClientStoreAction(Constants.Token.UPDATE, key, null, token)
    
    record = TokenStore.get(key)
    
    done = (json) ->
      handleServerStoreDoneAction(Constants.Token.UPDATE_DONE, key, json, token)
    
    fail = (xhr) ->
      handleServerStoreFailAction(Constants.Token.UPDATE_FAIL, key, xhr, token)
      
    SyncAPI.resendInvite(record.owner_id, key, done, fail)


  # Accept invite
  #
  acceptInvite: (key, sync_token = 'accept_invite') ->
    handleClientStoreAction(Constants.Role.CREATE, key, sync_token)
    handleClientStoreAction(Constants.Token.DELETE, key, sync_token)

    done = (json) ->
      handleServerStoreDoneAction(Constants.Role.CREATE_DONE, key, json, sync_token)
      handleServerStoreDoneAction(Constants.Token.DELETE_DONE, key, json, sync_token)

    fail = (xhr) ->
      handleServerStoreFailAction(Constants.Role.CREATE_FAIL, key, xhr, sync_token)
      handleServerStoreFailAction(Constants.Token.DELETE_FAIL, key, xhr, sync_token)
    
    SyncAPI.acceptInvite(TokenStore.get(key).owner_id, key, done, fail)


  # Cancel invite
  #
  cancelInvite: (key, token = 'cancel') ->
    handleClientStoreAction(Constants.Token.DELETE, key, token)
  
    record = TokenStore.get(key)
  
    done = (json) ->
      handleServerStoreDoneAction(Constants.Token.DELETE_DONE, key, json, token)

    fail = (xhr) ->
      handleServerStoreFailAction(Constants.Token.DELETE_FAIL, key, xhr, token)
    
    SyncAPI.cancelInvite(record.owner_id, key, done, fail)
