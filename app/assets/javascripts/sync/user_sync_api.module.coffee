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
    
