Dispatcher = require('dispatcher/dispatcher')


makeAction = (model_name, method_name, method_body, args...) ->  

  Dispatcher.handleClientAction
    type: "#{model_name}:#{method_name}"
    data: args.concat([method_name])

  done = (json) ->
    Dispatcher.handleServerAction
      type: "#{model_name}:#{method_name}:done"
      data: args.concat([json, method_name])

  fail = (xhr) ->
    Dispatcher.handleServerAction
      type: "#{model_name}:#{method_name}:fail"
      data: args.concat([xhr.responseJSON, xhr, method_name])

  method_body(args...)
  .done done
  .fail fail


exports.create = (model_name, methods) ->

  _.inject methods, (result, method_body, method_name) -> 
    result[method_name] = (args...) -> makeAction(model_name, method_name, method_body, args...)
    result
  , {}
