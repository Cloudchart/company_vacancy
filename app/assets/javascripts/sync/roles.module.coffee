# Exports
#
module.exports =
  
  revoke: (company_key, key, done, fail) ->
    $.ajax
      url:        "/companies/#{company_key}/access_rights/#{key}"
      type:       "DELETE"
      dataType:   "json"
    .done done
    .fail fail
