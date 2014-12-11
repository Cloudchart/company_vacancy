CursorFactory = (data, callback) ->
  
  # Initial immutable data
  #
  CurrData = Immutable.fromJS(data)

  # Cursor cache
  #
  CursorCache = Immutable.Map({})

  
  # Fetch existing Cursor or create a new one
  #
  fetch = (path) ->
    pathAsString = [].concat(path).join('/')

    unless CursorCache.has(pathAsString)
      CursorCache = CursorCache.set(pathAsString, new Cursor(path))

    CursorCache.get(pathAsString)
  
  
  # Update immutable data
  #
  update = (action, path, value) ->
    CurrData = switch action
      when 'set'
        CurrData.updateIn(path, -> Immutable.fromJS(value))
      when 'unset'
        CurrData.removeIn(path)
    
    callback(CurrData)
        


  # Cursor class
  #
  class Cursor
    

    constructor: (path) ->
      @path                 = [].concat(path)
      @__CURSOR_INSTANCE__  = true
    

    cursor: (path) ->
      fetch(@path.concat(path))
    
    
    deref: (notSetValue) ->
      @getIn([], notSetValue)
    
    get: (key, notSetValue) ->
      @getIn([key.toString()], notSetValue)
    
    getIn: (path, notSetValue) ->
      CurrData.getIn(@path.concat(path), notSetValue)
    
    
    set: (key, value) ->
      @setIn([key.toString()], value)
    
    setIn: (path, value) ->
      update('set', @path.concat(path), value)
      @
    

    update: (fn) ->
      @updateIn([], fn)
    
    updateIn: (path, fn) ->
      @setIn(path, fn(@getIn(path)))
    
    
    remove: (key) ->
      @removeIn([key.toString()])
    
    removeIn: (path) ->
      update('unset', @path.concat(path))
    
    
    clear: ->
      @removeIn([])
  
  
  # Root Cursor
  #
  fetch([])


# Exports
#
module.exports = CursorFactory