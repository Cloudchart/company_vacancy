##= require module

DraggableMixin = 

  _addOrRemoveEventListeners: (type) ->
    node  = @getDOMNode()
    self  = @
    
    ['start', 'move', 'end'].forEach (eventName) ->
      methodName = "onCCDrag#{eventName.charAt(0).toUpperCase()}#{eventName.slice(1)}"
      node["#{type}EventListener"]("cc:drag:#{eventName}", self[methodName]) if self[methodName] instanceof Function


  componentDidMount: ->
    @_addOrRemoveEventListeners('add')

  
  
  componentWillUnmount: ->
    @_addOrRemoveEventListeners('remove')


#
#
#

cc.module('react/mixins/draggable').exports = DraggableMixin
