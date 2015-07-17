# Dispatcher
#
Dispatcher  = require('dispatcher/dispatcher')
Query       = require('global_state/query')


# Endpoints
#
Endpoints = Immutable.fromJS


  'Viewer':
    url:          '/api/me'
    handle_id:    false
    store:        -> require('stores/user_store.cursor')


  'Block':
    url:          '/api/blocks'
    handle_id:    true
    require_id:   true
    store:        -> require('stores/block_store.cursor')


  'Favorite':
    url:          '/api/favorites'
    handle_id:    true
    require_id:   true
    store:        -> require('stores/favorite_store.cursor')


  'Feature':
    url:          '/api/features'
    handle_id:    true
    require_id:   true
    store:        -> require('stores/feature_store')


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


  'Post':
    url:          '/api/posts'
    handle_id:    true
    require_id:   true
    store:        -> require('stores/post_store.cursor')


  'Person':
    url:          '/api/people'
    handle_id:    true
    require_id:   true
    store:        -> require('stores/person_store.cursor')


  'Role':
    url:          '/api/roles'
    handle_id:    true
    require_id:   true
    store:        -> require('stores/role_store.cursor')


# Cached promises
#
cachedPromises = {}


# Storage
#
EmptyMap = Immutable.Map()
Storage = Immutable.Map()

diff = (lq, rq) ->
  Immutable.Map().withMutations (difference) ->
    rq.forEach (children, key) ->
      unless lq?.has(key)
        difference.set(key, children)
      else if children?
        children_difference = diff(lq.get(key), rq.get(key))
        difference.set(key, children_difference) if children_difference.size > 0


# Store data
#
store_data = (key, query, data) ->
  return if key == 'edges'

  Storage = Storage.withMutations (storage) ->
    if data
      type  = data.get('type')
      ids   = data.get('ids')

      if key == 'Viewer'
        ids.forEach (id) ->
          storage.mergeDeepIn(['Viewer'], query)
          storage.mergeDeepIn(['User', id], query)
      else
        ids.forEach (id) ->
          storage.mergeDeepIn([type, id], query)

      # ids.forEach (id) ->
      #   data.get(id, Immutable.Map()).forEach (id_or_ids, key) ->
      #     storage.setIn(['RELATIONS', id, key, 'type'], data.getIn([key, 'type']))
      #     storage.setIn(['RELATIONS', id, key, 'ids'], id_or_ids)

  query.get('children')?.forEach (child_query, child_key) ->
    store_data(child_key, child_query, data?.get(child_key))


# Fetch done
#
fetchDone = (response, query, options) ->
  store_data(query.endpoint, query.query, Immutable.fromJS(response.query))

  Dispatcher.handleServerAction
    type: 'fetch:done'
    data: [response]


# Fetch fail
#
fetchFail = (response) ->


# Fetch from storage
#
fetchFromStorage = (endpoint, query, id) ->
  getItemFromEndpoint(id, endpoint).withMutations (item) ->
    query.forEach (values, key) ->
      return if key == 'edges'

      relation = Storage.getIn(['RELATIONS', item.get('uuid'), key])
      return unless relation

      children_endpoint   = relation.get('type')
      children_id_or_ids  = relation.get('ids')
      children_query      = values.get('children', Immutable.Map())

      if Immutable.Iterable.isIterable(children_id_or_ids)
        children = children_id_or_ids.map (id) ->
          fetchFromStorage(children_endpoint, children_query, id)
        item.set(key, children)
      else
        item.set(key, fetchFromStorage(children_endpoint, children_query, children_id_or_ids))


getItemFromEndpoint = (id, endpoint) ->
  store = Endpoints.getIn([endpoint, 'store'])()
  if endpoint == 'Viewer'
    store.me().deref()
  else
    store.get(id)

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

  effective_query = query.toString()

  unless options.force == true

    stored_query  = Storage.get(query.endpoint)
    stored_query  = stored_query?.get(options.id) if options.id
    diff_query    = diff(stored_query, query.query)

    effective_query = Query.Query.stringify(diff_query)

    if diff_query.size == 0
      store = endpoint.get('store')()
      item  = getItemFromEndpoint(options.id, query.endpoint)
      if item
        return new Promise (done, fail) ->
          #item = fetchFromStorage(query.endpoint, query.query.get('children'), options.id)
          done(item.toJS())


  url       = buildURL(endpoint, options)
  cacheKey  = url + '?' + effective_query


  cachedPromises[cacheKey] ||= new Promise (done, fail) ->

    Promise.resolve $.ajax
      url:      url
      dataType: 'json'
      data:
        relations: effective_query if effective_query

    .then(
      (json) ->
        fetchDone(json, query, options)

        # item = fetchFromStorage(query.endpoint, query.query.get('children'), options.id)
        # done(item.toJS())
        done(json)

        delete cachedPromises[cacheKey]

    ,
      (xhr) ->
        fetchFail(xhr, query, options)
        fail(xhr)
        delete cachedPromises[cacheKey]
    )


# Exports
#
module.exports =

  fetch: fetch
