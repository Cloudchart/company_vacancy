###
  Used in:

  components/Person
###

##= require dispatcher/Dispatcher
##= require stores/PersonStore

# Imports
#
Dispatcher  = cc.require('cc.Dispatcher')
PersonStore = cc.require('cc.stores.PersonStore')


# Creator
#
Creator =


  update: (key, attributes = {}) ->
    console.log key, attributes
    


# Exports
#
cc.module('cc.actions.PersonActionsCreator').exports = Creator
