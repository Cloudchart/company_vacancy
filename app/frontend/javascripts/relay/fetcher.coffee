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

storeData = (endpoint, id_or_ids, fields, data) ->
  Storage = Storage.mergeDeepIn(['data'], data)


  # Storage = Storage.withMutations (storage) ->
  #   type  = query.type
  #   ids   = query.ids
  #
  #   typeData = data[TypeMaps[type]].reduce (memo, entry) ->
  #     memo[entry.uuid] = Object.assign(memo[entry.uuid] || {}, entry)
  #     memo
  #   , {}
  #
  #   ids.forEach (id) ->
  #     storage.mergeDeepIn([type, id, 'query'], fields)
  #
  #     record = typeData[id]
  #
  #     record = Object.keys(fields).reduce (memo, field) ->
  #       value = record[field]
  #
  #       if query[id] and query[id][field]
  #         value =
  #           ref:
  #             type: query[field].type
  #             id:   query[id][field]
  #
  #       memo[field] = value
  #       memo
  #     , {}
  #
  #     record.id = id
  #
  #     storage.mergeIn([type, id, 'data'], record)
  #
  # Object.keys(fields).forEach (field) ->
  #   storeData(query[field], fields[field], data)


# Get Record
#
getRecord = (endpoint, params, fields) ->
  return false unless record = Storage.getIn([endpoint, params.id, 'data'], false)

  record = record.toJS()

  Object.keys(fields).forEach (field) ->
    console.log field
    # if record[field] and ref = record[field].$ref
    #   if typeof ref.id.map is 'function'
    #     record[field] = ref.id.map (id) -> getRecord(ref.type, { id: id }, fields[field])
    #   else
    #     record[field] = getRecord(ref.type, { id: ref.id }, fields[field])

  record


# Fetch Done
#
fetchDone = (json, endpoint, params, fields, done) ->
  storeData(endpoint, params.id, fields, json)
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
        type:       endpoint
        id:         params.id
        relations:  fieldsAsString(fields)
    .done (json) ->
      fetchDone(json, endpoint, params, fields, done)
    .fail (data) ->
      fetchFail(data, endpoint, params, fields, fail)


# Exports
#
module.exports =
  fetch: fetch
