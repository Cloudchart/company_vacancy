cachedPromises = {}

# Exports
#
module.exports =
  create: (user) ->
    Promise.resolve $.ajax
      url: "/users/#{user.get('uuid')}/landings"
      type: 'POST'
      dataType: 'json'

  fetchOne: (id, options={}) ->
    delete cachedPromises['/landings/' + id] if options.force == true
    
    cachedPromises['/landings/' + id] ||= Promise.resolve $.ajax
      url:        '/landings/' + id
      type:       'GET'
      dataType:   'json'

  update: (item, attributes = {}, options = {}) ->
    data = _.reduce attributes, (memo, value, name) ->
      memo.append("landing[#{name}]", value) ; memo
    , new FormData

    Promise.resolve $.ajax
      url:      '/landings/' + item.get('uuid')
      type:     'PUT'
      dataType: 'json'
      processData: false
      contentType:  false
      data: data