##= require dispatcher/Dispatcher

# Imports
#
Dispatcher = cc.require('cc.Dispatcher')


# Variables
#

_items    = {}
_syncIDs  = []


# Functions
#

_checkPresence = (id) ->
  throw new Error("Company with id #{id} not found.")

addAll = (items) ->
  _.each items, addOne


addOne = (item) ->
  _items[item.uuid] = item


markAsSynchronizing = (id) ->
  _syncIDs.push(id) unless _.contains(_syncIDs, id)


unmarkAsSynchronizing = (id) ->
  _syncIDs = _.without(_syncIDs, id)


# Store
#
Store =
  
  
  all: ->
    _items
  

  get: (id) ->
    _items[id]


  $element: ->
    @$_element ||= document.createElement('emitter')
  

  emit: (type, detail) ->
    @$element().dispatchEvent(new CustomEvent(type, { detail: detail }))
  
  
  on: (type, callback) ->
    @$element().addEventListener(type, callback)
  

  off: (type, callback) ->
    @$element().removeEventListener(type, callback)
  

  emitChange: ->
    @emit('change')


# Dispatch token
#
Store.dispatchToken = Dispatcher.register (payload) ->
  action = payload.action
  
  switch action.type
  
    
    when 'company:sync:start'
      markAsSynchronizing(action.data)
      Store.emitChange()
  
  
    when 'company:sync:stop'
      unmarkAsSynchronizing(action.data)
      Store.emitChange()
  
  
    when 'company:receive:all'
      addAll(action.data)
      Store.emitChange()


    when 'company:receive:one'
      addOne(action.data)
      Store.emitChange()


# Exports
#
cc.module('cc.stores.CompanyStore').exports = Store
