# Pending promises
#
pendingPromises = {}


# Exports
#
module.exports =


  fetchAll: (params = {}, options = {}) ->
    delete pendingPromises['fetchAll'] if options.force == true

    pendingPromises['fetchAll'] ||= Promise.resolve $.ajax
      url:      '/pinboards'
      dataType: 'json'
      cache:    false
      data:     params


  fetchOne: (id, params = {}, options = {}) ->
    delete pendingPromises['fetchOne' + id] if options.force == true

    pendingPromises['fetchOne' + id] ||= Promise.resolve $.ajax
      url:        '/pinboards/' + id
      dataType:   'json'
      cache:      false
      data:       params


  create: (attributes = {}, options = {}) ->
    Promise.resolve $.ajax
      url:      '/pinboards'
      type:     'POST'
      dataType: 'json'
      data:
        pinboard: attributes


  update: (item, attributes = {}, options = {}) ->
    Promise.resolve $.ajax
      url:      '/pinboards/' + item.get('uuid')
      type:     'PUT'
      dataType: 'json'
      data:
        pinboard: attributes


  destroy: (id) ->
    Promise.resolve $.ajax
      url:      '/pinboards/' + id
      type:     'DELETE'
      dataType: 'json'


  request_access: (item) ->
    Promise.resolve $.ajax
      url:        "/pinboards/#{item.get('uuid')}/invites"
      type:       "POST"
      dataType:   "json"


  grant_access: (item, token, role) ->
    Promise.resolve $.ajax
      url:        "/pinboards/#{item.get('uuid')}/invites/#{token.get('uuid')}"
      type:       "PATCH"
      dataType:   "json"
      data:
        role:     role


  deny_access: (item, token) ->
    Promise.resolve $.ajax
      url:        "/pinboards/#{item.get('uuid')}/invites/#{token.get('uuid')}"
      type:       "DELETE"
      dataType:   "json"


  sendInvite: (item, attributes, options) ->
    Promise.resolve $.ajax
      url: "/pinboards/#{item.get('uuid')}/invites"
      type: 'POST'
      dataType: 'json'
      data:
        token: attributes

  follow: (key) ->
    Promise.resolve $.ajax
      url: "/pinboards/#{key}/follow"
      type: 'POST'
      dataType: 'json'

  unfollow: (key) ->
    Promise.resolve $.ajax
      url: "/pinboards/#{key}/unfollow"
      type: 'DELETE'
      dataType: 'json'
