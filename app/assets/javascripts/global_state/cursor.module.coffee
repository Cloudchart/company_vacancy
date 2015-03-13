CursorFactory = (data, callback) ->

  # Initial immutable data
  #
  CurrData = Immutable.fromJS(data)

  # Cursor cache
  #
  CursorCache = Immutable.Map({})

  # Transaction State
  #
  TransactionsCount = 0

  # Empty Sequence
  #
  EmptySeq = Immutable.Seq()


  # Fetch existing Cursor or create a new one
  #
  fetch = (path) ->
    pathAsString = [].concat(path).join('/')

    unless CursorCache.has(pathAsString)
      CursorCache = CursorCache.set(pathAsString, new Cursor(path))

    CursorCache.get(pathAsString)


  updateTimer = null

  # Update immutable data
  #
  update = (action, path, value) ->

    CurrData = switch action
      when 'set'
        CurrData.updateIn(path, -> Immutable.fromJS(value))
      when 'unset'
        CurrData.removeIn(path)

    clearTimeout updateTimer
    updateTime = setTimeout -> callback(CurrData)




  # Cursor class
  #
  class Cursor


    constructor: (path, @predicate, @type) ->
      @path                 = [].concat(path)
      @__CURSOR_INSTANCE__  = true


    cursor: (path) ->
      fetch(@path.concat(path))



    findCursor: (predicate) ->
      unless predicate instanceof Function
        throw new Error("GlobalState/Cursor: findCursor should receive a function.")

      new Cursor(@path, predicate, 'find')


    filterCursor: (predicate) ->
      unless predicate instanceof Function
        throw new Error("GlobalState/Cursor: filterCursor should receive a function.")

      new Cursor(@path, predicate, 'filter')


    applyPredicate: (data, path, notSetValue) ->
      value = data.getIn(path)

      @seq || if Immutable.Iterable.isIterable(value)
        @seq = value[@type].call(value, @predicate).toSeq()
      else
        notSetValue


    count: ->
      (seq = @deref(EmptySeq)).count.apply(seq, arguments)

    filter: ->
      (seq = @deref(EmptySeq)).filter.apply(seq, arguments)

    find: ->
      (seq = @deref(EmptySeq)).find.apply(seq, arguments)

    forEach: ->
      (seq = @deref(EmptySeq)).forEach.apply(seq, arguments)

    has: ->
      (seq = @deref(EmptySeq)).has.apply(seq, arguments)

    map: ->
      (seq = @deref(EmptySeq)).map.apply(seq, arguments)

    sortBy: ->
      (seq = @deref(EmptySeq)).sortBy.apply(seq, arguments)

    valueSeq: ->
      (seq = @deref(EmptySeq)).valueSeq.apply(seq, arguments)


    deref: (notSetValue) ->
      @getIn([], notSetValue)

    get: (key, notSetValue) ->
      @getIn([key?.toString()], notSetValue)

    getIn: (path, notSetValue) ->
      if @predicate
        @applyPredicate(CurrData, @path.concat(path), notSetValue)
      else
        CurrData.getIn(@path.concat(path), notSetValue)


    set: (key, value) ->
      @setIn([key?.toString()], value)

    setIn: (path, value) ->
      update('set', @path.concat(path), value)
      @


    update: (fn) ->
      @updateIn([], fn)

    updateIn: (path, fn) ->
      @setIn(path, fn(@getIn(path)))


    remove: (key) ->
      @removeIn([key?.toString()])

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
