# Imports
#
ActionsFactory = require('actions/server/actions_factory')


# Module
#
Module = ActionsFactory
  actions:  ['fetch', 'create', 'update']
  model:    'vacancy'


# Exports
#
module.exports = Module
