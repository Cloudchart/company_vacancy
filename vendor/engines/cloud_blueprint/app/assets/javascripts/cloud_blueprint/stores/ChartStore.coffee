##= require ../utils/ChartSyncAPI


# Imports
#
Dispatcher    = cc.require('cc.Dispatcher')
ChartSyncAPI  = cc.require('cc.blueprint.utils.ChartSyncAPI')


# Chart attributes
#
_knownAttributes = ['uuid', 'company_id', 'title', 'is_public', 'created_at', 'updated_at']


# Globals
#
_items        = {}
_descriptors  = {}


# Utils
#
_convertRawChart = (chart) ->
  chart = _.reduce _knownAttributes, (memo, attribute) ->
    memo[attribute] = chart[attribute]
    memo
  , {}
  
  chart.created_at = Date.parse(chart.created_at) || null if chart.created_at instanceof String
  chart.updated_at = Date.parse(chart.updated_at) || null if chart.updated_at instanceof String
  
  chart


_addAll = (charts) ->
  _.each(charts, _addOne)


_addOne = (chart) ->
  chart = _convertRawChart(chart)
  _items[chart.uuid] = chart
  _descriptors[chart.uuid] ||= {}
  _descriptors[chart.uuid].$synchronizedAt = + new Date


_update = (id, attributes = {}) ->
  throw new Error("Chart with id #{id} not found.") unless _items[id]

  nextChart = _.defaults({}, attributes, _items[id])

  if _.any(_knownAttributes, (name) -> nextChart[name] isnt _items[id][name])
    _descriptors[nextChart.uuid].$updatedAt = + new Date

  _items[id] = nextChart



_save = (id) ->
  throw new Error("Chart with id #{id} not found.") unless _items[id]
  
  return unless _descriptors[id].$updatedAt or _descriptors[id].$updatedAt > _descriptors[id].$synchronizedAt
  
  _items[id].isSynchronizing = true
  
  ChartSyncAPI.save(_items[id])


# Store
#
Store =
  
  
  allForCompany: (companyID) ->
    _.filter _items, (item) -> item.company_id == companyID
  

  all: ->
    _items
  
  
  get: (uuid) ->
    _items[uuid]
  
  
  $element: ->
    @$elementForEmitter ||= document.createElement('emitter')
  

  emit: (type, detail) ->
    @$element().dispatchEvent(new CustomEvent(type, { detail: detail }))
  
  
  on: (type, callback) ->
    @$element().addEventListener(type, callback)
  
  
  off: (type, callback) ->
    @$element().removeEventListener(type, callback)
  
  
  emitChange: ->
    @emit('change')


# Callbacks
#
Store.dispatchToken = Dispatcher.register (payload) ->
  action = payload.action
  
  switch action.type
  

    when 'chart:receive:all'
      Store.init(action.data)
      Store.emitChange()
    

    when 'chart:receive:one'
      _addOne(action.data)
      Store.emitChange()
    

    when 'chart:update'
      _update(action.data.id, action.data.attributes)
      _save(action.data.id) if action.data.shouldSave
      Store.emitChange()
    
    
# Exports
#
cc.module('cc.blueprint.stores.ChartStore').exports = Store
