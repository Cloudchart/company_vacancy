# Imports
#
tag = React.DOM


BlockActions  = require('actions/block_actions')
ModalActions  = require('actions/modal_actions')

PersonStore   = require('stores/person')

PersonChooser = require('components/editor/person_chooser')


# Main
#
Component = React.createClass


  gatherPeople: ->
    _.chain(@state.people)
      .map (person) =>
        (tag.div {
          key: person.uuid
        },
          (tag.i { className: 'fa fa-user' })
          person.full_name
          ' - '
          person.occupation
          (tag.button {
            onClick: @onDeleteButtonClick.bind(@, person.uuid)
          })
        )
      .value()


  
  onSelect: (key) ->
    identity_ids = @props.block.identity_ids[..] ; identity_ids.push(key)
    BlockActions.update(@props.key, { identity_ids: identity_ids })
    ModalActions.hide()


  onAddPersonClick: (event) ->
    ModalActions.show(PersonChooser({
      key:      @props.key
      onSelect: @onSelect
    }))
  
  
  onDeleteButtonClick: (key) ->
    identity_ids  = _.without(@props.block.identity_ids, key)
    BlockActions.update(@props.block.uuid, { identity_ids: identity_ids })
  
  
  getStateFromStores: ->
    people: PersonStore.filter (person) => _.contains(@props.block.identity_ids, person.uuid)
  
  
  getInitialState: ->
    @getStateFromStores()
    


  render: ->
    (tag.section {
      className: 'people'
    },
    
    
      @gatherPeople()
    
    
      (tag.div {
        className: 'add'
        onClick:    @onAddPersonClick
      },
        (tag.i { className: 'fa fa-plus' })
        'Add person'
      )
    
    )


# Exports
#
module.exports = Component
