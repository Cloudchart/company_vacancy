# Imports
#
Dispatcher    = require('dispatcher/dispatcher')
Constants     = require('constants')
TokenStore    = require('stores/token_store')
TokenSyncAPI  = require('sync/token_sync_api')


# Exports
#
module.exports =
  
  createCompanyInvite: (key, company_key, attributes = {}) ->
    Dispatcher.handleClientAction
      type:       Constants.Token.CREATE
      key:        key
      attributes: attributes
    
    TokenSyncAPI.createCompanyInvite(key, company_key)
  
  
  resendCompanyInvite: (key, company_key) ->
    Dispatcher.handleClientAction
      type:       Constants.Token.UPDATE
      key:        key
      attributes: {}
    
    TokenSyncAPI.resendCompanyInvite(key, company_key)
  
  
  deleteCompanyInvite: (key, company_key) ->
    Dispatcher.handleClientAction
      type: Constants.Token.DELETE
      key:  key
    
    TokenSyncAPI.deleteCompanyInvite(key, company_key)
