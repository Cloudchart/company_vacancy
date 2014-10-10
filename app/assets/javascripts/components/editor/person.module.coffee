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
      className:  'fa fa-times-circle-o remove'
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
  
  
  onPersonCreateDone: ->
    setTimeout ModalActions.hide
  
  
  onPersonUpdateDone: ->
    setTimeout ModalActions.hide
  
  
  getCloudFluxActions: ->
    'person:create-:done': @onPersonCreateDone
    'person:update-:done': @onPersonUpdateDone


  gatherPeople: ->
    _.chain(@state.people)
      .sortBy (person) => _.indexOf(@state.block.identity_ids, person.uuid)
      .map (person) => PersonComponent.call(@, person)
      .value()

  
  onSelectPerson: (key) ->
    identity_ids = @props.block.identity_ids[..] ; identity_ids.push(key)
    BlockActions.update(@props.key, { identity_ids: identity_ids })
    ModalActions.hide()


  onEditPersonClick: (key) ->
    return if @props.readOnly
    
    ModalActions.show(PersonForm({
      attributes: PersonStore.get(key).toJSON()
      onSubmit:   @onPersonFormSubmit.bind(@, key)
    }))
  
  
  onDeletePersonClick: (key) ->
    return if @props.readOnly

    identity_ids  = _.without(@props.block.identity_ids, key)
    BlockActions.update(@props.block.uuid, { identity_ids: identity_ids })
  
  
  # Person Chooser
  #
  onAddPersonClick: (event) ->
    return if @props.readOnly

    ModalActions.show(PersonChooser({
      key:            @props.key
      onSelect:       @onSelectPerson
      onCreateClick:  @onCreatePersonClick
    }))
  
  
  # Person Chooser
  #
  onCreatePersonClick: ->
    return if @props.readOnly

    newPersonKey = PersonStore.create({ company_id: @state.block.owner_id })

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
    block = BlockStore.get(@props.key)
    block:  block
    people: PersonStore.filter (person) -> _.contains(block.identity_ids, person.uuid)
  
  
  refreshStateFromStores: ->
    @setState(@getStateFromStores())
  
  
  componentDidMount: ->
    PersonStore.on('change', @refreshStateFromStores)
  
  
  componentWillUnount: ->
    PersonStore.off('change', @refreshStateFromStores)
  
  
  componentWillReceiveProps: ->
    @refreshStateFromStores()
  
  
  getInitialState: ->
    @getStateFromStores()
    

  render: ->
    people = @gatherPeople()
    
    (tag.section {
      className: 'people'
    },
      (tag.ul null,

        # People
        #
        _.map people, (person) -> (tag.li { key: person.props.key }, person)
        
        
        # Placeholder
        #
        PersonPlaceholderComponent.apply(@) unless @props.readOnly

      )

    )


# Exports
#
module.exports = Component
