# Imports
#
Dispatcher = require('dispatcher/dispatcher')


# Event Emitter
#
EventEmitter = 
  

    GetElementForEmitter: ->
      @_elementForEmitter ||= document.createElement('emitter')
    

    emit: (type, detail) ->
      @GetElementForEmitter().dispatchEvent(new CustomEvent(type, { detail: detail }))
    

    on: (type, callback) ->
      @GetElementForEmitter().addEventListener(type, callback)
  

    off: (type, callback) ->
      @GetElementForEmitter().removeEventListener(type, callback)
    
    
    emitChange: ->
      @emit('change')


# Store
#
Store =
  

  settings: new Immutable.Map
    isIdentityBoxVisible: false
  
  
  get: ->
    @settings.toJS()
  

  showIdentityBox: ->
    @toggleIdentityBox(false)
  
  
  hideIdentityBox: ->
    @toggleIdentityBox(true)
  

  toggleIdentityBox: (from) ->
    key   = 'isIdentityBoxVixible'
    from  = from || @settings.get(key)

    @settings = @settings.set('isIdentityBoxVisible', !from)
  
  
# Add EventEmitter to Store
#
_.extend Store, EventEmitter


#
#
Store.dispatchToken = Dispatcher.register (payload) ->
  action = payload.action
  
  switch action.type
    
    when 'identity_box:toggle'
      Store.toggleIdentityBox(action.from)
      Store.emitChange()


# Exports
#
module.exports = Store
