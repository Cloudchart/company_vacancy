# Pending promises
#
pendingPromises = {}


# Exports
#
module.exports =

  fetchAll: (params = {}, options = {}) ->
    signature = '/pins' + JSON.stringify(Immutable.Seq(params).sortBy((v, k) -> k))

    delete pendingPromises[signature] if options.force == true

    pendingPromises[signature] ||= Promise.resolve $.ajax
      url:      '/pins'
      dataType: 'json'
      data:     params


  fetchOne: (id, params = {}, options = {}) ->
    signature = '/pins/' + id + JSON.stringify(Immutable.Seq(params).sortBy((v, k) -> k))

    delete pendingPromises[signature] if options.force == true

    pendingPromises[signature] ||= Promise.resolve $.ajax
      url:      '/pins/' + id
      dataType: 'json'
      data:     params


  create: (attributes = {}, options = {}) ->
    Promise.resolve $.ajax
      url:      '/pins'
      type:     'POST'
      dataType: 'json'
      data:
        pin:    attributes


  update: (item, attributes = {}, options = {}) ->
    Promise.resolve $.ajax
      url:      '/pins/' + item.get('uuid')
      type:     'PATCH'
      dataType: 'json'
      data:
        pin:    attributes


  destroy: (item) ->
    Promise.resolve $.ajax
      url:      '/pins/' + item.get('uuid')
      type:     'DELETE'
      dataType: 'json'


  approve: (item) ->
    Promise.resolve $.ajax
      url:      '/pins/' + item.get('uuid') + '/approve'
      type:     'PATCH'
      dataType: 'json'
