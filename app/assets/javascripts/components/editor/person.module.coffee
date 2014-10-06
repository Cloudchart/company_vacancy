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


initials      = require('utils/initials')


# Person component
#
PersonComponent = (person) ->
  (tag.div {
    key:        person.uuid
    className:  'editor-person'
  },
  
    (tag.aside {
      className: if person.avatar_url then '' else 'no-avatar' 
      style:
        backgroundImage:  if person.avatar_url then "url(#{person.avatar_url})" else "none"
    },
      (tag.figure null, initials(person.full_name)) unless person.avatar_url
    )
    
    (tag.footer null,
      (tag.p { className: 'name' }, person.full_name)
      (tag.p { className: 'occupation' }, person.occupation)
    )
    
    (tag.button {
      onClick: @onDeletePersonClick.bind(@, person.uuid)
    }, (tag.i { className: 'fa fa-times' })) unless @props.readOnly
    
  )


# New Person component
#
NewPersonComponent = ->
  (tag.div {
    className:  'editor-person add'
    onClick:    @onAddPersonClick
  },
    (tag.aside null,
      (tag.figure null, '+')
    )
  )


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
      .sortBy (person) => _.indexOf(@state.block.identity_ids, person.uuid)
      .map (person) => PersonComponent.call(@, person)
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
      className: 'editor-people'
    },
    
    
      @gatherPeople()
      
      NewPersonComponent.apply(@)
    
    
    )


# Exports
#
module.exports = Component
