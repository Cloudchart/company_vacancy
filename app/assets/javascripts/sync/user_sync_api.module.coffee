cachedPromises = {}

# Exports
#
module.exports =
  
  fetchOne: (id, options = {}) ->
    delete cachedPromises['/users/' + id] if options.force == true
    
    cachedPromises['/users/' + id] ||= Promise.resolve $.ajax
      url:        '/users/' + id
      type:       'GET'
      dataType:   'json'
  
  
  fetchCurrentUser: (options = {}) ->
    delete cachedPromises['/profile/user'] if options.force == true
    
    cachedPromises['/profile/user/'] ||= Promise.resolve $.ajax
      url:        '/profile/user'
      type:       'GET'
      dataType:   'json'

  update: (item, attributes = {}, options = {}) ->
    data = _.reduce attributes, (memo, value, name) ->
      memo.append("user[#{name}]", value) ; memo
    , new FormData

    Promise.resolve $.ajax
      url:      '/users/' + item.get('uuid')
      type:     'PUT'
      dataType: 'json'
      processData: false
      contentType:  false
      data: data
    
  follow: (key) ->
    Promise.resolve $.ajax
      url: "/users/#{key}/follow"
      type: 'POST'
      dataType: 'json'

  unfollow: (key) ->
    Promise.resolve $.ajax
      url: "/users/#{key}/unfollow"
      type: 'DELETE'
      dataType: 'json'
