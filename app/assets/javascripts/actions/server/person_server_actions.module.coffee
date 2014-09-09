# Imports
#
ActionsFactory = require('actions/server/actions_factory')


# Module
#
Module = ActionsFactory
  actions:  ['fetch', 'create', 'update']
  model:    'person'


# Exports
#
module.exports = Module
