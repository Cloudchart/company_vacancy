# Imports
#
GlobalState = require('global_state/state')


# Exports
#
module.exports = GlobalState.createStore

  displayName:    'ParagraphStore'

  collectionName: 'paragraphs'
  instanceName:   'paragraph'


  findByOwner: (owner) ->
    @cursor.items.find (item) ->
      item.get('owner_type')  == owner.type and
      item.get('owner_id')    == owner.id
