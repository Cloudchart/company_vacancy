# Exports
#
module.exports =

  search: (query) ->
    query_param = if query then "?query=#{query}" else ""

    Promise.resolve $.ajax
      url:        "/companies/search#{query_param}"
      type:       "GET"
      dataType:   "json"
      cache:      false

  
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
    Promise.resolve $.ajax
      url:        "/profile/companies"
      type:       "GET"
      dataType:   "json"
      cache:      false
  

  update: (key, data, done, fail) ->
    data.tag_names = data.tag_names.join(',') if data.tag_names
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


  acceptInvite: (key, token_key) ->
    Promise.resolve $.ajax
      url:        "/companies/#{key}/invites/#{token_key}/accept"
      type:       "POST"
      dataType:   "json"
      cache:      false


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
