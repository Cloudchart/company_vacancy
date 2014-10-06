# Imports
#
tag = React.DOM


CloudFlux     = require('cloud_flux')


BlockActions  = require('actions/block_actions')
ModalActions  = require('actions/modal_actions')
PersonActions = require('actions/person_actions')

BlockStore    = require('stores/block_store')
PersonStore   = require('stores/person')

PersonChooser = require('components/editor/person_chooser')
PersonForm    = require('components/form/person_form')


# Main
#
Component = React.createClass


  mixins: [CloudFlux.mixins.Actions]
  
  
  onPersonCreateDone: ->
    setTimeout ModalActions.hide
  
  
  getCloudFluxActions: ->
    'person:create:done-': @onPersonCreateDone


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
            onClick: @onDeletePersonClick.bind(@, person.uuid)
          })
        )
      .value()

  
  onSelectPerson: (key) ->
    identity_ids = @props.block.identity_ids[..] ; identity_ids.push(key)
    BlockActions.update(@props.key, { identity_ids: identity_ids })
    ModalActions.hide()


  onAddPersonClick: (event) ->
    ModalActions.show(PersonChooser({
      key:            @props.key
      onSelect:       @onSelectPerson
      onCreateClick:  @onCreatePersonClick
    }))
  
  
  onCreatePersonClick: (event) ->
    newPersonKey = PersonStore.create({ company_id: @state.block.owner_id })

    ModalActions.show(PersonForm({
      attributes: PersonStore.get(newPersonKey).toJSON()
      onSubmit:   @onPersonFormSubmit.bind(@, newPersonKey)
    }), {
      beforeHide: ->
        PersonStore.remove(newPersonKey)
    })
  
  
  onPersonFormSubmit: (key, attributes) ->
    PersonActions.create(key, attributes.toJSON())
    @setState({ create_person: key })
  
  
  onDeletePersonClick: (key) ->
    identity_ids  = _.without(@props.block.identity_ids, key)
    BlockActions.update(@props.block.uuid, { identity_ids: identity_ids })
  
  
  getStateFromStores: ->
    block = BlockStore.get(@props.key)
    block:  block
    people: PersonStore.filter (person) -> _.contains(block.identity_ids, person.uuid)
  
  
  refreshStateFromStores: ->
    @setState(@getStateFromStores())
  
  
  componentDidMount: ->
    PersonStore.on('change', @refreshStateFromStore)
  
  
  componentWillUnount: ->
    PersonStore.off('change', @refreshStateFromStore)
  
  
  componentWillReceiveProps: ->
    @refreshStateFromStores()
  
  
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
