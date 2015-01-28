# Imports
#
Cursor  = require('global_state/cursor')
Store   = require('global_state/store')
uuid    = require('utils/uuid')


# Data
#
CurrRootData  = Immutable.fromJS({ meta: {}, stores: {} })
PrevRootData  = CurrRootData

LastUpdateId      = null
UpdateInProgress  = false

# Cursor
#
RootCursor = Cursor CurrRootData, (NextRootData, options = {}) ->
  
  PrevRootData = CurrRootData
  CurrRootData = NextRootData
  
  changedPaths = Callbacks
    .filter (callbacks, pathAsString) -> State.hasChanged(pathAsString.split('/'))
    .keySeq()
  
  setTimeout ->
    LastUpdateId      = uuid()
    UpdateInProgress  = true
    changedPaths.forEach (pathAsString) -> applyCallbacksForPath(pathAsString.split('/'))
    UpdateInProgress = false
  

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


addListener = (path, callback, uuid) ->
  pathAsString  = [].concat(path).join('/')
  Callbacks     = Callbacks.set(pathAsString, samePathCallbacks(pathAsString).add(callback))


removeListener = (path, callback) ->
  pathAsString  = [].concat(path).join('/')
  Callbacks     = Callbacks.set(pathAsString, samePathCallbacks(pathAsString).remove(callback))


# State
#
State =
  
  
  createStore: Store.create
  
  
  cursor: (path = []) ->
    RootCursor.cursor(path)
  
  
  addListener: (path, callback) ->
    addListener(path, callback)
  

  hasChanged: (path) ->
    not Immutable.is(CurrRootData.getIn(path), PrevRootData.getIn(path))
    
  
  
  mixin:
    
    
    componentDidUpdate: ->
      @__componentDidUpdateTransactionId = LastUpdateId
    
    
    shouldComponentUpdateWithGlobalStateCheck: (nextProps, nextState) ->
      return false if @__componentDidUpdateTransactionId == LastUpdateId and UpdateInProgress
      @shouldComponentUpdateWithoutGlobalStateCheck(nextProps, nextState)
    
    
    onGlobalStateChangeWithGlobalStateCheck: ->
      return false if @__globalStateChangeTransactionId == LastUpdateId and UpdateInProgress

      @__globalStateChangeTransactionId = LastUpdateId

      @onGlobalStateChangeWithoutGlobalStateCheck()
    

    componentWillMount: ->
      @shouldComponentUpdateWithoutGlobalStateCheck = @shouldComponentUpdate || => true
      @shouldComponentUpdate = @shouldComponentUpdateWithGlobalStateCheck

      @onGlobalStateChangeWithoutGlobalStateCheck = @onGlobalStateChange || => @setState({})
      @onGlobalStateChange = @onGlobalStateChangeWithGlobalStateCheck
    

    componentDidMount: ->
      if typeof @onGlobalStateChange == 'function'
        if @props.cursor.__CURSOR_INSTANCE__
          addListener(@props.cursor.path, @onGlobalStateChange)
        else
          Immutable.Seq(@props.cursor).forEach (cursor, key) =>
            addListener(cursor.path, @onGlobalStateChange)


    componentWillUnmount: ->
      if typeof @onGlobalStateChange == 'function'
        if @props.cursor.__CURSOR_INSTANCE__
          removeListener(@props.cursor.path, @onGlobalStateChange)
        else
          Immutable.Seq(@props.cursor).forEach (cursor, key) =>
            removeListener(cursor.path, @onGlobalStateChange)


# Exports
#
module.exports = State
