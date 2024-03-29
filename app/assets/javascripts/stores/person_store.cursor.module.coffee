# Imports
#
GlobalState = require('global_state/state')

BlockIdentityStore = require('stores/block_identity_store')

# Exports
#
module.exports = GlobalState.createStore

  displayName: 'PersonStore'

  collectionName: 'people'
  instanceName:   'person'


  findByCompany: (company_id) ->
    @filter (person) -> person.get("company_id") == company_id

  filterForUser: (user_id) ->
    @filter (person) -> person.get("user_id") == user_id

  filterForBlock: (id) ->
    block_identities      = BlockIdentityStore.filterForBlock(id)

    block_identities_ids  = block_identities
      .sortBy (item) -> item.get('position')
      .map    (item) -> item.get('identity_id')
      .valueSeq()

    @cursor.items
      .filter (item) ->
        block_identities_ids.contains(item.get('uuid'))

      .sortBy (item) ->
        block_identities_ids.indexOf(item.get('uuid'))
