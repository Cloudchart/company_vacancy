###
  Used in:

  utils/BlockIdentitySyncAPI
###

##= require dispatcher/Dispatcher
##= require_tree ./ServerActions

# Imports
#
Dispatcher = cc.require('cc.Dispatcher')

BlockIdentityServerActions = cc.require('cc.actions.ServerActions.BlockIdentity')


# Creator
#
Creator =
  
  noop: ->


# Extensions
#

_.extend Creator, BlockIdentityServerActions
  

# Exports
#
cc.module('cc.actions.ServerActionsCreator').exports = Creator
