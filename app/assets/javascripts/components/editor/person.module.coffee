# @cjsx React.DOM

# Imports
#
tag = React.DOM
cx  = React.addons.classSet;


CloudFlux     = require('cloud_flux')


BlockActions  = require('actions/block_actions')
ModalActions  = require('actions/modal_actions')
PersonActions = require('actions/person_actions')

BlockStore    = require('stores/block_store')
PersonStore   = require('stores/person')

PersonAvatar  = require('components/shared/person_avatar')
PersonChooser = require('components/editor/person_chooser')
PersonForm    = require('components/form/person_form')

Draggable     = require('components/shared/draggable')


# Person Placeholder component
#
PersonPlaceholderComponent = ->
  (tag.li {
    className: 'placeholder'
  },
    (tag.div {
      className: 'person editable'
    },
      (tag.aside {
        className: 'avatar'
      },
        (tag.figure {
          onClick: @onAddPersonClick
        },
          (tag.i { className: 'fa fa-plus' })
          (tag.i { className: 'hint' }, 'Add person')
        )
      )
    )
  )


# Person component
#
PersonComponent = (person) ->
  (tag.div {
    key:        person.uuid
    className:  cx({ person: true, editable: !@props.readOnly })
  },
  
    (tag.i {
      className:  'fa fa-times remove'
      onClick:    @onDeletePersonClick.bind(@, person.uuid)
    }) unless @props.readOnly
    
    PersonAvatar({
      value:      person.full_name
      avatarURL:  person.avatar_url
      onClick:    @onEditPersonClick.bind(@, person.uuid)
      readOnly:   true
    })
    
    (tag.footer null,
      (tag.p { className: 'name' }, person.full_name)
      (tag.p { className: 'occupation' }, person.occupation)
    )
    
  )


# Main
#
Component = React.createClass


  mixins: [CloudFlux.mixins.Actions]


  statics:
    isEmpty: (block_id) ->
      BlockStore.get(block_id).identity_ids.size == 0
      
  

  onPersonCreateDone: ->
    setTimeout ModalActions.hide
  
  
  onPersonUpdateDone: ->
    setTimeout ModalActions.hide
  
  
  getCloudFluxActions: ->
    'person:create-:done': @onPersonCreateDone
    'person:update-:done': @onPersonUpdateDone


  gatherPeople: ->
    @state.peopleSeq
      .sortBy((person) => @state.identityIdsSeq.indexOf(person.uuid))
      .map((person) => PersonComponent.call(@, person))
      
  
  onSelectPerson: (key) ->
    return if @props.readOnly

    identity_ids = @state.identityIdsSeq.toList().push(key)

    BlockActions.update(@props.key, { identity_ids: identity_ids.toArray() })

    ModalActions.hide()


  onEditPersonClick: (key) ->
    return if @props.readOnly
    
    ModalActions.show(PersonForm({
      attributes: PersonStore.get(key).toJSON()
      onSubmit:   @onPersonFormSubmit.bind(@, key)
    }))
  
  
  onDeletePersonClick: (key) ->
    return if @props.readOnly

    identity_ids = @state.identityIdsSeq.toList().remove(@state.identityIdsSeq.indexOf(key))

    BlockActions.update(@props.key, { identity_ids: identity_ids.toArray() })
  
  
  # Person Chooser
  #
  onAddPersonClick: (event) ->
    return if @props.readOnly

    ModalActions.show(PersonChooser({
      key:            @props.key
      company_id:     @props.company_id
      onSelect:       @onSelectPerson
      onCreateClick:  @onCreatePersonClick
    }))
  
  
  # Person Chooser
  #
  onCreatePersonClick: ->
    return if @props.readOnly

    newPersonKey = PersonStore.create({ company_id: @props.company_id })

    ModalActions.show(PersonForm({
      attributes: PersonStore.get(newPersonKey).toJSON()
      onSubmit:   @onPersonFormSubmit.bind(@, newPersonKey)
    }), {
      beforeHide: ->
        PersonStore.remove(newPersonKey)
    })
  
  
  # Person Form
  #
  onPersonFormSubmit: (key, attributes) ->
    person = PersonStore.get(key)
    if person.uuid
      PersonActions.update(key, attributes.toJSON())
    else
      PersonActions.create(key, attributes.toJSON())
  
  
  getStateFromStores: ->
    identityIdsSeq  = Immutable.Seq(BlockStore.get(@props.key).identity_ids)
    peopleSeq       = Immutable.Seq(PersonStore.filter((person) -> identityIdsSeq.contains(person.uuid)))
    
    peopleSeq:        peopleSeq
    identityIdsSeq:   identityIdsSeq
  
  
  refreshStateFromStores: ->
    @setState(@getStateFromStores())
  
  
  componentDidMount: ->
    PersonStore.on('change', @refreshStateFromStores)
  
  
  componentWillUnmount: ->
    PersonStore.off('change', @refreshStateFromStores)
  
  
  componentWillReceiveProps: ->
    @refreshStateFromStores()
  
  
  getInitialState: ->
    @getStateFromStores()
    

  render: ->
    people = @gatherPeople().map (person) ->
      <li key={person.props.key}>{person}</li>
    
    <ul>
      { people.toArray() }
      { PersonPlaceholderComponent.apply(@) unless @props.readOnly }
    </ul>


# Exports
#
module.exports = Component
