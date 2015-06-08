# Dispatcher
#
Dispatcher = require('dispatcher/dispatcher')


# Endpoints
#
Endpoints = Immutable.fromJS


  Block:
    handle_id:    true
    store:        -> require('stores/block_store.cursor')

  'Viewer':
    url:          '/api/me'
    handle_id:    false
    store:        -> require('stores/user_store.cursor')
    relations:
      'readable_pinboards':   'Pinboard'
      'writable_pinboards':   'Pinboard'

  'User':
    url:          '/api/users'
    handle_id:    true
    require_id:   true
    store:        -> require('stores/user_store.cursor')


  'Unicorns':
    url:          '/api/unicorns'
    handle_id:    false
    store:        -> require('stores/user_store.cursor')


  'Company':
    url:          '/api/companies'
    handle_id:    true
    require_id:   true
    store:        -> require('stores/company_store.cursor')


  'Pinboard':
    url:          '/api/pinboards'
    handle_id:    true
    require_id:   true
    store:        -> require('stores/pinboard_store')
    relations:
      'pins':     'Pin'
      'posts':    'Post'
      'user':     'User'


  'SystemPinboards':
    url:          '/api/pinboards/system'
    handle_id:    false
    require_id:   false
    store:        -> require('stores/pinboard_store')


  'Pin':
    url:          '/api/pins'
    handle_id:    true
    require_id:   true
    store:        -> require('stores/pin_store')
    relations:
      'parent':   'Pin'
      'user':     'User'


  'Post':
    url:          '/api/posts'
    handle_id:    true
    require_id:   true
    store:        -> require('stores/post_store.cursor')
    relations:
      'blocks':   'Block'
      'owner':    -> 'Company'


# Cached promises
#
cachedPromises = {}


# Storage
#
Storage = Immutable.Map()


# Fetch done
#
fetchDone = (response, query, options) ->
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
  unless Endpoints.has(query.endpoint)
    throw new Error("GlobalState/Fetcher: no endpoint specified for #{query.endpoint}")

  endpoint = Endpoints.get(query.endpoint)

  if endpoint.get('require_id') and not options.id
    throw new Error("GlobalState/Fetcher: no id provided for #{query.endpoint} endpoint")


  url       = buildURL(endpoint, options)
  relations = query.toString()
  cacheKey  = url + '?' + relations


  delete cachedPromises[cacheKey] if options.force == true


  if endpoint.get('handle_id') and options.id
    delete cachedPromises[cacheKey] unless endpoint.get('store')().has(options.id)


  cachedPromises[cacheKey] ||= new Promise (done, fail) ->

    Promise.resolve $.ajax
      url:      url
      dataType: 'json'
      data:
        relations: relations if relations

    .then(
      (json) ->
        fetchDone(json, query, options)
        done(json)
    ,
      (xhr) ->
        delete cachedPromises[cacheKey]
        fetchFail(xhr, query, options)
        fail(xhr)
    )


# Exports
#
module.exports =

  fetch: fetch
