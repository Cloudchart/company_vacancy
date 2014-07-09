DroppableMixin = 

  _addOrRemoveEventListeners: (type) ->
    node  = @getDOMNode()
    self  = @
    
    ['enter', 'move', 'leave', 'drop'].forEach (eventName) ->
      methodName = "onCCDrop#{eventName.charAt(0).toUpperCase()}#{eventName.slice(1)}"
      node["#{type}EventListener"]("cc:drop:#{eventName}", self[methodName]) if self[methodName] instanceof Function


  componentDidMount: ->
    @_addOrRemoveEventListeners('add')

  
  
  componentWillUnmount: ->
    @_addOrRemoveEventListeners('remove')


#
#
#

@cc.react.mixins.Droppable = DroppableMixin
