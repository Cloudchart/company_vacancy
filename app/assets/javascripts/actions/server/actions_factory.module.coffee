# Imports
#
Dispatcher = require('dispatcher/dispatcher')


# Action data for DONE
#
actionDataForDONE = (action, args) ->
  switch action

    when 'fetch'
      json:   if _.isArray(args[0]) then args[0] else [args[0]]
    
    else
      model:  args[0]
      json:   args[1]


# Action data for FAIL
#
actionDataForFAIL = (action, args) ->
  switch action
    
    when 'fetch'
      xhr:    args[0]
      json:   args[0].responseJSON
    
    else
      model:  args[0]
      xhr:    args[1]
      json:   args[1].responseJSON


# Factory
#
Factory = (options = {}) ->
  throw new Error("Module #{module.id}: No actions.") unless _.isArray(options.actions)
  throw new Error("Module #{module.id}: No model.") unless _.isString(options.model)
  
  _.reduce options.actions, (memo, action) ->

    # Done
    #
    memo["#{action}Done"] = ->
      
      actionData      = actionDataForDONE(action, arguments)
      actionData.type = "#{options.model}:#{action}:done"
      
      Dispatcher.handleServerAction actionData
    
    
    # Fail
    #
    memo["#{action}Fail"] = ->
      
      actionData      = actionDataForFAIL(action, arguments)
      actionData.type = "#{options.model}:#{action}:fail"
      
      Dispatcher.handleServerAction actionData
    
    memo
  , {}


# Exports
#
module.exports = Factory
