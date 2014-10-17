###
  Used in:

  components/editor/BlockIdentityController
  components/editor/IdentitySelector
  react_components/editor/blocks/people
###

##= require dispatcher/Dispatcher
##= require stores/BlockIdentityStore
##= require utils/BlockIdentitySyncAPI

# Imports
#
Dispatcher            = cc.require('cc.Dispatcher')
BlockIdentityStore    = cc.require('cc.stores.BlockIdentityStore')
BlockIdentitySyncAPI  = cc.require('cc.utils.BlockIdentitySyncAPI')


# Creator
#
Creator =
  
  create: (attributes) ->
    model = BlockIdentityStore.create(attributes)

    Dispatcher.handleClientAction
      type: 'block/identity:receive:created'
      data: model
    
    BlockIdentitySyncAPI.create(model)
  
  
  destroy: (key) ->
    model = BlockIdentityStore.find(key)
    
    Dispatcher.handleClientAction
      type: 'block/identity:destroy'
      data: model
    
    BlockIdentitySyncAPI.destroy(model)
  

# Exports
#
cc.module('cc.actions.BlockIdentityActionsCreator').exports = Creator
