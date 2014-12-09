# Imports
#
Cursor = require('global_state/cursor')


# Data
#
CurrRootData = Immutable.Map({})
PrevRootData = Immutable.Map({})


# Cursor
#
RootCursor = Cursor CurrRootData, (NextRootData, options = {}) ->
  PrevRootData = CurrRootData
  CurrRootData = NextRootData
  
  Callbacks.forEach (callback, pathAsString) ->
    path = pathAsString.split('/')
    applyCallbacksForPath(path) if State.hasChanged(path)


# Callbacks
#
Callbacks = Immutable.Map({})


applyCallbacksForPath = (path) ->
  pathAsString  = [].concat(path).join('/')
  currData      = CurrRootData.getIn(path)
  prevData      = PrevRootData.getIn(path)
  
  samePathCallbacks(pathAsString).forEach (callback) ->
    callback(currData, prevData)


samePathCallbacks = (pathAsString) ->
  Callbacks.get(pathAsString, Immutable.Set())


addListener = (path, callback) ->
  pathAsString  = [].concat(path).join('/')
  Callbacks     = Callbacks.set(pathAsString, samePathCallbacks(pathAsString).add(callback))


removeListener = (path, callback) ->
  pathAsString  = [].concat(path).join('/')
  Callbacks     = Callbacks.set(pathAsString, samePathCallbacks(pathAsString).remove(callback))


# State
#
State =
  
  
  cursor: (path = []) ->
    RootCursor.cursor(path)
  
  
  addListener: (path, callback) ->
    addListener(path, callback)
  

  hasChanged: (path) ->
    not Immutable.is(CurrRootData.getIn(path), PrevRootData.getIn(path))
    
  
  
  mixin:
    

    componendDidMount: ->
      if typeof @onGlobalStateChange == 'function'
        if @props.cursor.__CURSOR_INSTANCE__
          addListener(@props.cursor.path, @onGlobalStateChange)
        else
          Immutable.Sequence(@props.cursor).forEach (cursor, key) =>
            addListener(cursor.path, @onGlobalStateChange)
    

    componentWillUnmount: ->
      if typeof @onGlobalStateChange == 'function'
        if @props.cursor.__CURSOR_INSTANCE__
          removeListener(@props.cursor.path, @onGlobalStateChange)
        else
          Immutable.Sequence(@props.cursor).forEach (cursor, key) =>
            removeListener(cursor.path, @onGlobalStateChange)


# Exports
#
module.exports = State
