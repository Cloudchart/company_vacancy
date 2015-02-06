# Dispatcher
#
Dispatcher = require('dispatcher/dispatcher')


# Endpoints
#
Endpoints = Immutable.fromJS
  'Viewer':
    url:          '/api/me'
    handle_id:    false
    store:        -> require('stores/user_store')


  'User':
    url:          '/api/users'
    handle_id:    true
    require_id:   true
    store:        -> require('stores/user_store')


  'Unicorns':
    url:          '/api/unicorns'
    handle_id:    false
    store:        -> require('stores/user_store')


  'Pinboard':
    url:          '/api/pinboards'
    handle_id:    true
    require_id:   true
    store:        -> require('stores/pinboard_store')


  'Pin':
    url:          '/api/pins'
    handle_id:    true
    require_id:   true
    store:        -> require('stores/pin_store')


# Cached promises
#
cachedPromises = {}


# Fetch done
#
fetchDone = (response, query, options) ->
  require('global_state/state').cursor().transaction ->
    Dispatcher.handleServerAction
      type: 'fetch:done'
      data: [response]


# Fetch fail
#
fetchFail = (response) ->


# Build URL
#
buildURL = (endpoint, options = {}) ->
  endpoint.get('url') + if endpoint.get('handle_id') and options.id then '/' + options.id else ''


# Fetch
#
fetch = (query, options = {}) ->
  unless Endpoints.has(query.model)
    throw new Error("GlobalState/Fetcher: no endpoint specified for #{query.model}")

  endpoint = Endpoints.get(query.model)

  if endpoint.get('require_id') and not options.id
    throw new Error("GlobalState/Fetcher: no id provided for #{query.model} endpoint")


  url       = buildURL(endpoint, options)
  relations = query.relations.replace(/\s*/g, '')
  cacheKey  = url + '?' + relations


  delete cachedPromises[cacheKey] if options.force == true


  if endpoint.get('handle_id') and options.id
    delete cachedPromises[cacheKey] unless endpoint.get('store')().has(options.id)


  promise = cachedPromises[cacheKey] ||= Promise.resolve $.ajax
    url:          url
    dataType:     'json'
    data:
      relations:  relations

  promise.then(
    (json) ->
      fetchDone(json, query, options)
    ,
    (xhr) ->
      delete cachedPromises[cacheKey]
      fetchFail(xhr, query, options)
  )

  promise


# Exports
#
module.exports =

  fetch: fetch
