# Imports
#
TokenStore          = require('stores/token_store')
TokenServerActions  = require('actions/server/token_actions')

# Exports
#
module.exports =
  

  fetchByCompany: (company_key) ->
    done = (TokenServerActions.fetchDone or _.noop)
    fail = (TokenServerActions.fetchFail or _.noop)

    Promise.resolve(
      $.ajax
        url:        "/companies/#{company_key}/invites"
        type:       "GET"
        dataType:   "json"
    ).then(done, fail)
  

  createCompanyInvite: (key, company_key) ->
    model = TokenStore.get(key)
    
    done = (TokenServerActions.createDone or _.noop).bind(null, key)
    fail = (TokenServerActions.createFail or _.noop).bind(null, key)

    Promise.resolve(
      $.ajax
        url:        "/companies/#{company_key}/invites"
        type:       "POST"
        dataType:   "json"
        data:
          token:    model
    ).then(done, fail)
  
  
  deleteCompanyInvite: (key, company_key) ->
    model = TokenStore.get(key)
    
    done = (TokenServerActions.deleteDone or _.noop).bind(null, key)
    fail = (TokenServerActions.deleteFail or _.noop).bind(null, key)

    Promise.resolve(
      $.ajax
        url:        "/invites/#{key}"
        type:       "DELETE"
        dataType:   "json"
    ).then(done, fail)
