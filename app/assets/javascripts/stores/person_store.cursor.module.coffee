# Imports
#
GlobalState = require('global_state/state')


# Exports
#
module.exports = GlobalState.createStore

  displayName: 'PersonStore'
  
  collectionName: 'people'
  instanceName:   'person'

  findByCompany: (company_id) ->
    @filter (person) -> person.get("company_id") == company_id
