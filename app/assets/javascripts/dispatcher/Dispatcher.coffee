###
  Used in:

  actions/BlockIdentityActionsCreator
  actions/PersonActionsCreator
  actions/ServerActionsCreator
  actions/ServerActions/BlockIdentityServerActions
  dispatcher/dispatcher
###

# Dispatcher
#
class Dispatcher extends Flux.Dispatcher


  handleServerAction: (action) ->
    payload =
      action: action
      source: 'server'
    @dispatch(payload)
  
  
  handleClientAction: (action) ->
    payload =
      action: action
      source: 'client'
    @dispatch(payload)


# Exports
#
cc.module('cc.Dispatcher').exports = new Dispatcher
