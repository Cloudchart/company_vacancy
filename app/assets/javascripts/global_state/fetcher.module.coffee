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


# Store data
#
storeData = (response, endpointKey) ->
  endpoint  = Endpoints.get(endpointKey)

  if Immutable.Iterable.isKeyed(response)

    unless store = endpoint.get('store')
      console.error "GlobalState/Fetcher: unknown store for #{endpointKey}"
      return null

    store   = store() if store instanceof Function
    record  = Immutable.Map(store.cursor.items.get(response.get('id')))

    record.withMutations (data) ->

      response.forEach (value, key) ->
        return if key is 'id'

        unless childEndpoint = endpoint.getIn(['relations', key])
          console.error "GlobalState/Fetcher: unknown reference to #{key} from #{endpointKey}"
          return null

        childEndpoint = childEndpoint(record) if childEndpoint instanceof Function
        data.set(key, storeData(value, childEndpoint))

    Storage = Storage.updateIn [endpointKey], (data) ->
      (data || Immutable.Map()).set(record.get('uuid'), record)

    record


  else if Immutable.Iterable.isIndexed(response)
   response.map (value, index) -> storeData(value, endpointKey)



# Fetch done
#
fetchDone = (response, query, options) ->
  require('global_state/state').cursor().transaction ->
    Dispatcher.handleServerAction
      type: 'fetch:done'
      data: [response]

  storeData(Immutable.fromJS(response.query), query.endpoint)



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
        done fetchDone(json, query, options)
    ,
      (xhr) ->
        delete cachedPromises[cacheKey]
        fail fetchFail(xhr, query, options)
    )


# Exports
#
module.exports =

  fetch: fetch
