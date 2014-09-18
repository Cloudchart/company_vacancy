module.exports =
  
  fetchByCompany: (company_key, done, fail) ->
    $.ajax
      url:        "/companies/#{company_key}/access_rights"
      type:       "GET"
      dataType:   "json"
    .done done
    .fail fail
