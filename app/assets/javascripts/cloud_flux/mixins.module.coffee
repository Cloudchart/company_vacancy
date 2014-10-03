# Imports
#
Dispatcher = require('dispatcher/dispatcher')


# ActionsMixin
#
ActionsMixin =
  

  componentDidMount: ->
    return unless _.isFunction(@getCloudFluxActions)
    @__dispatchToken = Dispatcher.register (payload) =>
      if action = @getCloudFluxActions()[payload.action.type]
        action.apply(@, payload.action.data)
  
  componentWillUnmount: ->
    return unless _.isFunction(@getCloudFluxActions)
    Dispatcher.unregister(@__dispatchToken)


# Exports
#
module.exports =
  
  Actions: ActionsMixin
