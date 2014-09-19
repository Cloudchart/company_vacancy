# Exports
#
module.exports =
  
  createAsCompanyInvite: (data, key, done, fail) ->
    $.ajax
      url:        "/companies/#{key}/invites"
      type:       "POST"
      dataType:   "json"
      data:
        token:    data
    .done done
    .fail fail
