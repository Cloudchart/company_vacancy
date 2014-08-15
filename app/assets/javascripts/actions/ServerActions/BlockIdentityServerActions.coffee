##= require dispatcher/Dispatcher


# Imports
#
Dispatcher = cc.require('cc.Dispatcher')


# Exports
#
cc.module('cc.actions.ServerActions.BlockIdentity').exports =

  doneReceiveBlockIdentities: (json) ->
    json = [json] unless _.isArray(json)

    Dispatcher.handleServerAction
      type: 'block/identity:receive:done'
      data: json


  doneCreateBlockIdentity: (model, json) ->
    Dispatcher.handleServerAction
      type: 'block/identity:create:done'
      data:
        model:  model
        json:   json


  failCreateBlockIdentity: (model) ->
    Dispatcher.handleServerAction
      type: 'block/identity:create:fail'
      data: model


  doneDestroyBlockIdentity: (model) ->
    Dispatcher.handleServerAction
      type: 'block/identity:destroy:done'
      data: model


  failDestroyBlockIdentity: (model, xhr) ->
    Dispatcher.handleServerAction
      type: 'block/identity:destroy:fail'
      data:
        model:  model
        xhr:    xhr
