# Imports
#
TokenStore          = require('stores/token_store')
TokenServerActions  = require('actions/server/token_actions')

# Exports
#
module.exports =
  

  # Fetch tokens by Company ID
  #
  fetchByCompany: (company_key, token) ->
    done = (TokenServerActions.fetchDone or _.noop).bind(null, token)
    fail = (TokenServerActions.fetchFail or _.noop).bind(null, token)

    Promise.resolve(
      $.ajax
        url:        "/companies/#{company_key}/invites"
        type:       "GET"
        dataType:   "json"
    ).then(done, fail)
  

  # Create Company Invite
  #
  createCompanyInvite: (key, company_key) ->
    done = (TokenServerActions.createDone or _.noop).bind(null, key)
    fail = (TokenServerActions.createFail or _.noop).bind(null, key)

    Promise.resolve(
      $.ajax
        url:        "/companies/#{company_key}/invites"
        type:       "POST"
        dataType:   "json"
        data:
          token:    TokenStore.get(key).toJSON()
    ).then(done, fail)
  
  
  # Resend Company Invite
  #
  resendCompanyInvite: (key, company_key) ->
    done = (TokenServerActions.updateDone or _.noop).bind(null, key)
    fail = (TokenServerActions.updateFail or _.noop).bind(null, key)
    
    Promise.resolve(
      $.ajax
        url:        "/companies/#{company_key}/invites/#{key}/resend"
        type:       "PATCH"
        dataType:   "json"
    ).then(done, fail)
  

  # Delete Company Invite
  #
  deleteCompanyInvite: (key, company_key) ->
    done = (TokenServerActions.deleteDone or _.noop).bind(null, key)
    fail = (TokenServerActions.deleteFail or _.noop).bind(null, key)

    Promise.resolve(
      $.ajax
        url:        "/companies/#{company_key}/invites/#{key}"
        type:       "DELETE"
        dataType:   "json"
    ).then(done, fail)
