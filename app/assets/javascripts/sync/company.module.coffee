# Exports
#
module.exports =
  
  
  fetch: (key, done, fail) ->
    $.ajax
      url:        "/companies/#{key}"
      type:       "GET"
      dataType:   "json"
      cache:      false
    .done done
    .fail fail
  
  # TODO: move to cloud_profile
  fetchAll: (done, fail) ->
    $.ajax
      url:        "/profile/companies"
      type:       "GET"
      dataType:   "json"
      cache:      false
    .done done
    .fail fail
  
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
  
  
  createBlock: (key, attributes, done, fail) ->
    $.ajax
      url:        "/companies/#{key}/blocks"
      type:       "POST"
      dataType:   "json"
      data:
        block:    attributes
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


  acceptInvite: (key, token_key, done, fail) ->
    $.ajax
      url:        "/companies/#{key}/invites/#{token_key}/accept"
      type:       "POST"
      dataType:   "json"
    .done done
    .fail fail


  follow: (key, done, fail) ->
    $.ajax
      url: "/companies/#{key}/follow"
      type: 'POST'
      dataType: 'json'
    .done done
    .fail fail


  unfollow: (key, done, fail) ->
    $.ajax
      url: "/companies/#{key}/unfollow"
      type: 'DELETE'
      dataType: 'json'
    .done done
    .fail fail


  verifySiteUrl: (key, done, fail) ->
    $.ajax
      url:        "/companies/#{key}/verify_site_url"
      type:       "GET"
      dataType:   "json"
    .done done
    .fail fail
