# Dispatcher
#
Dispatcher = require('dispatcher/dispatcher')


# Endpoints
#
Endpoints = Immutable.fromJS
  'Viewer':
    url:        '/api/me'
    handle_id:  false
    store:      -> require('stores/user_store')


  'Unicorns':
    url:        '/api/unicorns'
    handle_id:  false
    store:      -> require('stores/user_store')


  'Pin':
    url:        '/api/pins'
    handle_id:  true
    store:      -> require('stores/pin_store')


# Cached promises
#
cachedPromises = {}


# Fetch done
#
fetchDone = (response) ->
  require('global_state/state').cursor().transaction ->
    Dispatcher.handleServerAction
      type: 'fetch:done'
      data: [response]


# Fetch fail
#
fetchFail = (response) ->


# Fetch
#
fetch = (query, options = {}) ->
  unless Endpoints.has(query.model)
    throw new Error("GlobalState/Fetcher: no url specified for #{query.model} endpoint")

  endpoint = Endpoints.get(query.model)

  relations = query.relations.replace(/\s*/g, '')
  url       = endpoint.get('url') + if endpoint.get('handle_id') then '/' + options.id else ''
  cacheKey  = url + '?' + relations


  delete cachedPromises[cacheKey] if options.force == true


  if endpoint.get('handle_id') and options.id
    delete cachedPromises[cacheKey] unless endpoint.get('store')().has(options.id)


  promise = cachedPromises[cacheKey] ||= Promise.resolve $.ajax
    url:          url
    dataType:     'json'
    data:
      relations:  relations

  promise.then(fetchDone, (xhr) -> delete cachedPromises[cacheKey] ; fetchFail(xhr))

  promise


# Exports
#
module.exports =

  fetch: fetch
