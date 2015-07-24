# Constants
#
TypeMaps =
  Pin:        'pins'
  User:       'users'
  Pinboard:   'pinboards'


# Gather Fields
#
gatherFields = (selectionSet) ->
  return {} unless selectionSet and selectionSet.selections
  result = selectionSet.selections.reduce (memo, item) ->
    memo[item.name.value] = Object.assign(memo[item.name.value] || {}, gatherFields(item.selectionSet))
    memo
  , {}


# Map fields as String
#
fieldsAsString = (fields) ->
  return null unless fields
  Object.keys(fields).map (field) ->
    field + if children = fieldsAsString(fields[field]) then "{#{children}}" else ""
  .join(',')


# Store Data
#
Storage = Immutable.Map()

storeData = (root, data, fields, storage) ->
  if Array.isArray(root)
    return root.forEach (record) -> storeData(record, data, fields, storage)

  return unless record = root

  if record.$ref
    type    = root.$ref.type
    id      = root.$ref.id
    record  = data[type][id]

    storage.mergeDeepIn([type, id, 'query'], fields)
    storage.mergeDeepIn([type, id, 'data'], record)

  Object.keys(fields).forEach (field) ->
    storeData(record[field], data, fields[field], storage)


# Get Record
#
getRecord = (endpoint, params, fields) ->
  return false unless record = Storage.getIn([endpoint, params.id, 'data'], false)

  record = record.toJS()

  Object.keys(fields).forEach (field) ->
    records           = record[field]
    records_as_array  = [].concat(records)

    result = records_as_array.map (child) ->
      if child and child.$ref
        getRecord(child.$ref.type, { id: child.$ref.id }, fields[field])
      else
        child

    record[field] = if Array.isArray(records) then result else result[0]

  record


# Fetch Done
#
fetchDone = (json, endpoint, params, fields, done) ->
  Storage = Storage.withMutations (storage) ->
    storeData(json['root'], json['data'], fields, storage)

  done(getRecord(endpoint, params, fields))


# Fetch Fail
#
fetchFail = (data, endpoint, params, fields, fail) ->
  fail()


# Fetch
#
fetch = (endpoint, query, params) ->
  fields = gatherFields(query.selectionSet)

  return record if record = getRecord(endpoint, params, fields)

  new Promise (done, fail) ->
    $.ajax
      url:        '/api/relay'
      type:       'GET'
      dataType:   'json'
      data:
        type:     endpoint
        id:       params.id
        fields:   fieldsAsString(fields)
    .done (json) ->
      fetchDone(json, endpoint, params, fields, done)
    .fail (data) ->
      fetchFail(data, endpoint, params, fields, fail)


# Exports
#
module.exports =
  fetch: fetch
