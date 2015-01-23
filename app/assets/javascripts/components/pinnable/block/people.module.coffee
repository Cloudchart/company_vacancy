# @cjsx React.DOM

# Imports
#
GlobalState = require('global_state/state')


# Stores
#

BlockIdentityStore  = require('stores/block_identity_store')
PersonStore         = require('stores/person_store.cursor')
BlockStore          = require('stores/block_store.cursor')


# Components
#

PersonComponent = require('components/pinnable/block/person')


# Exports
#
module.exports = React.createClass


  mixins: [GlobalState.mixin]
  
  
  gatherPeople: ->
    @props.cursor.identities
      .filter (identity)  => identity.get('block_id') == @props.uuid 
      .sortBy (identity)  -> identity.get('position')
      .map    (identity)  => @props.cursor.people.get(identity.get('identity_id'))
      .filter (person)    -> person
      .valueSeq()
  
  
  onGlobalStateChange: ->
    @setState
      refreshed_at: + new Date


  getDefaultProps: ->
    cursor:
      identities:   BlockIdentityStore.cursor.items
      people:       PersonStore.cursor.items
  
  
  renderPerson: (person) ->
    uuid = person.get('uuid')
    PersonComponent({ key: uuid, uuid: uuid, cursor: PersonStore.cursor.items.cursor([uuid]) })


  renderPeople: ->
    people = @gatherPeople() ; return null if people.count() == 0
    
    <ul className="people">
      { people.map(@renderPerson).toArray() }
    </ul>


  render: ->
    @renderPeople() 
