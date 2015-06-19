# Imports
#
Dispatcher = require('dispatcher/dispatcher')


# Ensure
#
ensure = (something) ->
  success = !!something
  result  =
    done: (callback) ->
      callback() if success
      result
    fail: (callback) ->
      callback() unless success
      result


# Global State accessor
#
GlobalState = -> require('global_state/state')


# Empty Sequence
#
EmptySequence = Immutable.Seq({})
EmptySet      = Immutable.Set()
EmptyMap      = Immutable.Map()


# Store default
#
StoreDefaults = Immutable.Seq
  displayName:      'UndefinedStore'
  collectionName:   null
  instanceName:     null
  syncAPI:          null
  foreignKeys:      []
  populateKeys:     []


# Pending queries
#
pendingQueries = {}


# Store
#
class BaseStore


  constructor: ->
    ensure(@collectionName)
      .fail =>
        throw new Error("#{@displayName}: collectionName is undefined.")

    ensure(@instanceName)
      .fail =>
        throw new Error("#{@displayName}: instanceName is undefined.")

    @cursor   =
      items:    GlobalState().cursor(['stores', @collectionName, 'items'])
      indices:  GlobalState().cursor(['stores', @collectionName, 'indices'])

    @indices  = @prepareIndices()

    @populateKeys = Immutable.Set(@populateKeys).union([@collectionName, @instanceName])

    @empty    = EmptySequence


  populate: (json) ->
    data = @populateKeys
      .reduce (memo, key) ->
        memo.concat(json[key])
      , []
      .filter (item) -> item

    Immutable.Seq(data).forEach (item) =>
      @cleanupIndices(item.uuid)

      @indices.forEach (data, name) =>
        foreign_key = data.fields.map((name) => item[name]).join("::")
        @cursor.indices.setIn([name, foreign_key], @cursor.indices.getIn([name, foreign_key], EmptySet).add(item.uuid))

      currItem = @cursor.items.get(item.uuid, Immutable.Map({ id: item.uuid }))
      @cursor.items.set(item.uuid, currItem.mergeDeep(item))


  remove: (id) ->
    @cleanupIndices(id)
    @cursor.items.remove(id)

  #
  #
  prepareIndices: ->
    Immutable.Seq(@foreignKeys).reduce (reduction, data, name) ->
      reduction.set name,
        fields: Immutable.Seq([].concat(data.fields))
    , Immutable.Map()


  cleanupIndices: (id) ->
    @indices.forEach (data, name) =>
      @cursor.indices.get(name, EmptySequence).forEach (items, foreign_key) =>
        @cursor.indices.setIn([name, foreign_key], items.remove(id))


  byFK: (name, values...) ->
    @cursor.indices.getIn([name, values.join('::')], EmptySet).map (id) =>
      @cursor.items.get(id)


  indexedCursor: (name, values...) =>
    @cursor.indices.cursor([name].concat(values))



  #
  #

  has: (id) ->
    @cursor.items.has(id)

  get: (id) ->
    @cursor.items.get(id)

  filter: (predicate) ->
    @cursor.items.filter(predicate)


  # Fetch
  #

  fetchAll: (params = {}, options = {}) ->
    ensure(@syncAPI)
      .fail =>
        throw new Error("#{@displayName}: syncAPI is undefined.")

    promise = @syncAPI.fetchAll(params, options)
    promise.then(@fetchDone, @fetchFail)
    promise


  fetchOne: (id, params = {}, options = {}) ->
    ensure(@syncAPI)
      .fail =>
        throw new Error("#{@displayName}: syncAPI is undefined.")

    if @syncAPI.fetchSome

      query = @displayName + '?' + JSON.stringify(Immutable.Seq(params).concat(options).sortBy((v, k) -> k))

      if pendingQueries[query]
        clearTimeout pendingQueries[query].timeout

      (pendingQueries[query] ||= { timeout: null, ids: [] }).ids.push(id)

      pendingQueries[query].timeout = setTimeout =>

        ids     = Immutable.Set(pendingQueries[query].ids)

        delete pendingQueries[query]

        promise = @syncAPI.fetchSome(ids.toArray(), params, options)
        promise.then(@fetchDone, @fetchFail)
        promise

      , 10

      null


    else

      promise = @syncAPI.fetchOne(id, params, options)
      promise.then(@fetchDone, @fetchFail)
      promise


  fetchDone: (json) ->
    Dispatcher.handleServerAction
      type: 'fetch:done'
      data: [json]


  fetchFail: ->


  # Create
  #

  create: (params = {}, options = {}) ->
    promise = @syncAPI.create(params, options)
    promise.then(@createDone, @createFail)
    promise


  createDone: (json) ->
    @fetchOne(json.id)


  # Update
  #
  update: (id, params = {}, options = {}) ->
    promise = @syncAPI.update(@cursor.items.get(id), params, options)
    promise.then(@updateDone, @updateFail)
    promise


  updateDone: (json) ->
    @fetchOne(json.id, null, { force: true })


  # Destroy
  #

  destroy: (id, params = {}, options = {}) ->
    currItem = @cursor.items.get(id)

    promise = @syncAPI.destroy(currItem, params, options)
    promise.then(@destroyDone, @destroyFail)
    promise


  destroyDone: (json) ->
    @remove(json.id)


# Register dispatcher
#
registerDispatcher = (store, descriptor) ->

  mappings = Immutable.Seq
    'fetch:done': store.populate

  if descriptor.serverActions instanceof Function
    mappings = mappings.concat(descriptor.serverActions.apply(store))

  store.dispatchToken = Dispatcher.register (payload) ->
    type  = payload.action.type
    data  = payload.action.data

    if mappings.has(type)
      mappings.get(type).apply(store, data)


classes = {}


# Create
#
create = (descriptor = {}) ->

  Store = class extends BaseStore


  StoreDefaults.forEach (value, name) ->
    Store.prototype[name] = descriptor[name] ? StoreDefaults.get(name)
    delete descriptor[name]


  Immutable.Seq(descriptor).forEach (value, name) ->
    Store.prototype[name] = value if value instanceof Function


  store = new Store
  console.log JSON.stringify Immutable.Seq(BaseStore.prototype).concat(Store.prototype).keySeq()
  Immutable.Seq(BaseStore.prototype).concat(Store.prototype).keySeq().toSet().forEach (name) ->
    store[name] = store[name].bind(store) if store[name] instanceof Function

  registerDispatcher(store, descriptor)

  store


# Exports
#
module.exports =
  Store:  BaseStore
  create: create
