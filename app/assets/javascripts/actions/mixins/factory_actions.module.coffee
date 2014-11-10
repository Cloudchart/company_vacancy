Dispatcher = require('dispatcher/dispatcher')


makeAction = (model_name, method_name, method_body, id, attributes) ->  

  Dispatcher.handleClientAction
    type: "#{model_name}:#{method_name}"
    data: [id, attributes, method_name]

  done = (json) ->
    Dispatcher.handleServerAction
      type: "#{model_name}:#{method_name}:done"
      data: [id, attributes, json, method_name]

  fail = (xhr) ->
    Dispatcher.handleServerAction
      type: "#{model_name}:#{method_name}:fail"
      data: [id, attributes, xhr.responseJSON, xhr, method_name]

  if method_body == 'default'
    require("sync/#{model_name}_sync_api")[method_name](id, attributes, done, fail)
  else
    method_body(id, attributes)
    .done done
    .fail fail


exports.create = (model_name, methods) ->

  _.inject methods, (result, method_body, method_name) -> 
    result[method_name] = (id, attributes = {}) -> makeAction(model_name, method_name, method_body, id, attributes)
    result
  , {}
