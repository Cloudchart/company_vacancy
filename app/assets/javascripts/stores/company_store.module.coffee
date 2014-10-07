# Imports
#
Dispatcher    = require('dispatcher/dispatcher')
EventEmitter  = require('utils/event_emitter')
Constants     = require('constants')


# Data
#
data    = new Immutable.Map({})


deserialize = (attributes = {}) ->
  attributes


# Store
#
Store = {}

_.extend Store, {},
  
  deserialize: (attributes) ->
    deserialize(attributes)
  

  get: (key) ->
    data.get(key).toJS()
  

  add: (json) ->
    found_record = data.find (record) -> record.get('uuid') == json.uuid

    if found_record
      throw new Error('CompanyStore.add: Record with key ' + json.uuid + ' already exists in store.')
    else
      data = data.set(json.uuid, Immutable.fromJS(json))

    Store.emitChange()
  
  
  update: (key, attributes) ->
    record = data.find (record) -> record.get('uuid') == key

    unless record
      throw new Error('CompanyStore.update: Record with key ' + key + ' doesn\'t exist in store.')
    else
      record  = record.merge(@deserialize(attributes))
      data    = data.set(key, record)
    
    Store.emitChange()


# Extend Store with event emitter
#
_.extend Store, EventEmitter


# Exports
#
module.exports = Store
