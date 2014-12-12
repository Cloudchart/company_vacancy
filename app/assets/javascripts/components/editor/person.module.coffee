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
  <li className="placeholder">
    <div className="person editable">
      <aside className="avatar">
        <figure onClick={@onAddPersonClick}>
          <i className="cc-icon cc-plus" />
          <i className="hint">Add person</i>
        </figure>
      </aside>
    </div>
  </li>


# Person component
#
PersonComponent = (person) ->
  removeButton = =>
    onClick = @onDeletePersonClick.bind(@, person.uuid)
    <i className="fa fa-times remove" onClick={onClick} />
  
  <div key={person.uuid} className={cx({ person: true, editable: !@props.readOnly })}>
    {removeButton() unless @props.readOnly}
    
    <PersonAvatar
      value     = {person.full_name}
      avatarURL = {person.avatar_url}
      onClick   = {@onEditPersonClick.bind(@, person.uuid)}
      readOnly  = {true}
    />
    
    <footer>
      <p className="name">{person.full_name}</p>
      <p className="occupation">{person.occupation}</p>
    </footer>
  </div>


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

  getHelperPeopleIndexes: (people) ->
    peopleLength = people.size
    indexes = {}

    if peopleLength > 1 && peopleLength % 3 == 1
      indexes.hangingIndex = peopleLength - 4

    if peopleLength == 1
      indexes.shiftIndex = 0
    else if peopleLength % 3 == 0
      indexes.shiftIndex = peopleLength - 3
    else
      indexes.shiftIndex = peopleLength - 2

    indexes
  
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
    }), {
      beforeShow: =>
        @setState
          popupOpened: true

      beforeHide: =>
        @setState
          popupOpened: false
    })
  
  
  # Person Chooser
  #
  onCreatePersonClick: ->
    return if @props.readOnly

    newPersonKey = PersonStore.create({ company_id: @props.company_id })

    ModalActions.show(PersonForm({
      attributes: PersonStore.get(newPersonKey).toJSON()
      onSubmit:   @onPersonFormSubmit.bind(@, newPersonKey)
    }), {
      beforeHide: =>
        @setState
          popupOpened: false
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
    _.extend @getStateFromStores(),
      hovered: false
      popupOpened: false

  onMouseEnter: ->
    @setState
      hovered: true

  onMouseLeave: ->
    if !@state.popupOpened
      @setState
        hovered: false

  render: ->
    people = @gatherPeople()
    indexes = @getHelperPeopleIndexes(people)

    people = people.map (person, index) =>
      classes = []
      if _.has(indexes, "hangingIndex") && index == indexes.hangingIndex
        classes.push "hanging"
      if !@props.readOnly && _.has(indexes, "shiftIndex") && index == indexes.shiftIndex
        classes.push "shifting"
      className = classes.join(' ')

      <li key={person.props.key} className={className}>{person}</li>
    
    <ul className={cx(hovered: @state.hovered)} onMouseLeave={@onMouseLeave} onMouseEnter={@onMouseEnter}>
      { people.toArray() }
      { PersonPlaceholderComponent.apply(@) unless @props.readOnly }
    </ul>


# Exports
#
module.exports = Component
