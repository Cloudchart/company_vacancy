# Cached promises
#

promisesCache = {}

# Exports
#
module.exports =

  fetchAll: (company_id, done, fail) ->
    $.ajax
      url:        "/companies/#{company_id}/posts"
      type:       "GET"
      dataType:   "json"
    .done done
    .fail fail


  fetchSome: (ids, params = {}, options = {}) ->
    query = JSON.stringify(Immutable.Seq(params).sortBy((v, k) -> k))
    delete promisesCache['fetchSome' + ids + query] if options.force == true

    promisesCache['fetchSome' + ids + query] ||= Promise.resolve $.ajax
      url:      '/posts/fetch'
      type:     'GET'
      dataType: 'json'
      data:     Object.assign({}, params, { ids: ids })


  fetchOne: (id, params = {}, options = {}) ->
    query = JSON.stringify(Immutable.Seq(params).sortBy((v, k) -> k))
    delete promisesCache['fetchOne' + id + query] if options.force == true

    promisesCache['fetchOne' + id] ||= Promise.resolve $.ajax
      url:      '/posts/' + id
      type:     'GET'
      dataType: 'json'
      data:     params


  create: (company_id, attributes, done, fail) ->
    $.ajax
      url: "/companies/#{company_id}/posts"
      type: "POST"
      dataType: "json"
      data:
        post: attributes
    .done done
    .fail fail


  update: (key, attributes, done, fail) ->
    attributes.tag_names = attributes.tag_names.join(',') if attributes.tag_names

    $.ajax
      url: "/posts/#{key}"
      type: "PUT"
      dataType: "json"
      data:
        post: attributes
    .done done
    .fail fail

  destroy: (key, attributes, done, fail) ->
    $.ajax
      url: "/posts/#{key}"
      type: "DELETE"
      dataType: "json"
    .done done
    .fail fail
