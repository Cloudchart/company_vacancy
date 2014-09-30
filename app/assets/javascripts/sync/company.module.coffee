# Exports
#
module.exports =
  
  
  update: (key, data, done, fail) ->
    data = _.reduce data, ((memo, value, key) -> memo.append("company[#{key}]", value) ; memo), new FormData
    
    $.ajax
      url:          "/companies/#{key}"
      type:         "PUT"
      dataType:     "json"
      data:         data
      contentType:  false
      processData:  false
    .done done
    .fail fail
  
  
  fetchAccessRights: (key, done, fail) ->
    $.ajax
      url:        "/companies/#{key}/access_rights"
      type:       "GET"
      dataType:   "json"
    .done done
    .fail fail


  fetchInviteTokens: (key, done, fail) ->
    $.ajax
      url:        "/companies/#{key}/invites"
      type:       "GET"
      dataType:   "json"
    .done done
    .fail fail
  
  
  sendInvite: (key, data, done, fail) ->
    $.ajax
      url:        "/companies/#{key}/invites"
      type:       "POST"
      dataType:   "json"
      data:
        token:    data
    .done done
    .fail fail


  resendInvite: (key, token_key, done, fail) ->
    $.ajax
      url:        "/companies/#{key}/invites/#{token_key}/resend"
      type:       "PUT"
      dataType:   "json"
    .done done
    .fail fail


  cancelInvite: (key, token_key, done, fail) ->
    $.ajax
      url:        "/companies/#{key}/invites/#{token_key}"
      type:       "DELETE"
      dataType:   "json"
    .done done
    .fail fail


  revokeRole: (key, role_key, done, fail) ->
    $.ajax
      url:        "/companies/#{key}/access_rights/#{role_key}"
      type:       "DELETE"
      dataType:   "json"
    .done done
    .fail fail
