# Imports
#
TokenStore = require('stores/token_store')

# Exports
#
module.exports =
  
  createCompanyInvite: (key, company_key) ->
    model = TokenStore.get(key)

    Promise.resolve(
      $.ajax
        url:        "/companies/#{company_key}/invites"
        type:       "POST"
        dataType:   "json"
        data:
          token:    model
    )
