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
  <div key="placeholder" className="item placeholder">
    <div className="person editable">
      <aside className="avatar">
        <figure onClick={@onAddPersonClick}>
          <i className="cc-icon cc-plus" />
          <i className="hint">Add person</i>
        </figure>
      </aside>
    </div>
  </div>


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
      
  modalBeforeOpen: ->
    if @isMounted()
      @setState
        hovered: true

  modalBeforeHide: (event) ->
    if @isMounted()
      @setState
        hovered: false

  onPersonCreateDone: ->
    setTimeout ModalActions.hide
  
  
  onPersonUpdateDone: ->
    setTimeout ModalActions.hide
  
  
  getCloudFluxActions: ->
    'person:create-:done': @onPersonCreateDone
    'person:update-:done': @onPersonUpdateDone


  gatherPeople: ->
    @getPeopleHtml(
      @state.peopleSeq
        .sortBy((person) => @state.identityIdsSeq.indexOf(person.uuid))
        .map((person) => PersonComponent.call(@, person))
        .reduce((memo, person, index, people) ->
          # form rows in groups of three
          if (lastRow = memo.slice(-1)[0]) && (lastRow.length < 3) && !(people.size % 3 == 1 && index == people.size - 2) # if the array has one element in the last group, add a previous one
            lastRow.push person
          else
            memo.push [person]

          memo
        , [])
    )

  getPeopleHtml: (people) ->
    if people.length > 0
      people.map (rows, index) =>
        <div key={index} className="row">
          {
            items = rows.map (person) ->
              <div className="item" key={person.props.key}>{person}</div>

            if !@props.readOnly && index == people.length - 1
              items.push PersonPlaceholderComponent.apply(@)

            items
          }
        </div>
    else
      <div className="row">
        {PersonPlaceholderComponent.apply(@)}
      </div>



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
    }), {
      beforeShow: @modalBeforeOpen
      beforeHide: @modalBeforeHide
    })
  
  
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
      beforeShow: @modalBeforeOpen
      beforeHide: @modalBeforeHide
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
      beforeShow: @modalBeforeOpen

      beforeHide: =>
        @modalBeforeHide()

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
    setTimeout =>
      if @isMounted()
        @setState
          animated: true
    , 400

    identityIdsSeq  = Immutable.Seq(BlockStore.get(@props.key).identity_ids)
    peopleSeq       = Immutable.Seq(PersonStore.filter((person) -> identityIdsSeq.contains(person.uuid)))
    
    peopleSeq:        peopleSeq
    identityIdsSeq:   identityIdsSeq
    animated:         false
  
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
      animated: true
      hovered: false

  render: ->
    classes = cx(
      list: true
      hovered: @state.hovered
      animated: @state.animated
    )

    <div className = {classes}>
      {@gatherPeople()}
    </div>


# Exports
#
module.exports = Component
