# @cjsx React.DOM

# Imports
#
cx  = React.addons.classSet;


CloudFlux     = require('cloud_flux')


ModalActions  = require('actions/modal_actions')
PersonActions = require('actions/person_actions')

BlockStore    = require('stores/block_store')
PersonStore   = require('stores/person')

PersonAvatar  = require('components/shared/person_avatar')
PersonChooser = require('components/editor/person_chooser')
PersonForm    = require('components/form/person_form')


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

  # Component specifications
  #
  propTypes:
    company_id:  React.PropTypes.string.isRequired
    isSingle:    React.PropTypes.bool
    onAdd:       React.PropTypes.func.isRequired
    onDelete:    React.PropTypes.func.isRequired
    readOnly:    React.PropTypes.bool
    selected:    React.PropTypes.instanceOf(Immutable.Seq)

  getDefaultProps: ->
    isSingle: false
    readOnly: false
    selected: Immutable.Seq()
  
  getInitialState: ->
    _.extend @getStateFromStores(@props),
      animated: true
      hovered: false

  getStateFromStores: (props) ->
    setTimeout =>
      if @isMounted()
        @setState
          animated: true
    , 400

    peopleSeq = Immutable.Seq(PersonStore.filter((person) => props.selected.contains(person.uuid)))
    
    peopleSeq: peopleSeq
    animated:  false
  
  refreshStateFromStores: ->
    @setState(@getStateFromStores(@props))


  mixins: [CloudFlux.mixins.Actions]

  modalBeforeOpen: ->
    if @isMounted() && !@props.readOnly
      @setState
        hovered: true

  modalBeforeHide: (event) ->
    if @isMounted() && !@props.readOnly
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
        .sortBy((person) => @props.selected.indexOf(person.uuid))
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
              <div className="item" key={person.props.uuid}>{person}</div>

            if !@props.readOnly && !@props.isSingle && index == people.length - 1
              items.push PersonPlaceholderComponent.apply(@)

            items
          }
        </div>
    else if !@props.readOnly
      <div className="row">
        {PersonPlaceholderComponent.apply(@)}
      </div>
    else
      null



  onSelectPerson: (uuid) ->
    return if @props.readOnly

    @props.onAdd(uuid)

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
  
  
  onDeletePersonClick: (uuid) ->
    return if @props.readOnly

    @props.onDelete(uuid)
  
  # Person Chooser
  #
  onAddPersonClick: (event) ->
    return if @props.readOnly

    ModalActions.show(PersonChooser({
      company_id:     @props.company_id
      onSelect:       @onSelectPerson
      onCreateClick:  @onCreatePersonClick
      selected:       @props.selected
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

  
  onPersonFormSubmit: (key, attributes) ->
    person = PersonStore.get(key)
    if person.uuid
      PersonActions.update(key, attributes.toJSON())
    else
      PersonActions.create(key, attributes.toJSON())
  

  componentDidMount: ->
    PersonStore.on('change', @refreshStateFromStores)
  
  componentWillUnmount: ->
    PersonStore.off('change', @refreshStateFromStores)

  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))


  render: ->
    classes = cx(
      "people-list": true
      hovered:       @state.hovered
      frozen:        @props.readOnly || @props.isSingle
      animated:      @state.animated
    )

    <div className = {classes}>
      {@gatherPeople()}
    </div>


# Exports
#
module.exports = Component
