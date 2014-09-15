# Event Emitter
#
module.exports = 

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
