# Dispatcher
#
Dispatcher = require('dispatcher/dispatcher')


# Endpoints
#
Endpoints = Immutable.fromJS
  'Viewer':
    url:        '/api/me'
    handle_id:  false

  'Unicorns':
    url:        '/api/unicorns'
    handle_id:  false


  'Pin':
    url:        '/api/pins'
    handle_id:  true


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

  relations = query.relations.replace(/\s*/g, '')
  url       = Endpoints.getIn([query.model, 'url']) + if Endpoints.getIn([query.model, 'handle_id']) then '/' + options.id else ''

  delete cachedPromises[url + '?' + relations] if options.force == true

  promise = cachedPromises[url + '?' + relations] ||= Promise.resolve $.ajax
    url:          url
    dataType:     'json'
    data:
      relations:  relations

  promise.then(fetchDone, fetchFail)

  promise


# Exports
#
module.exports =

  fetch: fetch
