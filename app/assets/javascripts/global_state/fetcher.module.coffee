# Dispatcher
#
Dispatcher = require('dispatcher/dispatcher')


# Endpoints
#
Endpoints = Immutable.fromJS
  'Viewer':
    url: '/api/me'


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
  id        = options.id

  delete cachedPromises[relations + id] if options.force == true

  promise = cachedPromises[relations + id] ||= Promise.resolve $.ajax
    url:          Endpoints.getIn([query.model, 'url'])
    dataType:     'json'
    data:
      relations:  relations

  promise.then(fetchDone, fetchFail)

  promise


# Exports
#
module.exports =

  fetch: fetch
