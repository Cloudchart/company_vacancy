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
colors        = require('utils/colors')


# Person component
#
PersonComponent = (person) ->
  personInitials = initials(person.full_name)
  
  (tag.div {
    key:        person.uuid
    className:  'editor-person'
  },
  
    (tag.i {
      className:  'fa fa-times-circle-o'
      onClick:    @onDeletePersonClick.bind(@, person.uuid)
    }) unless @props.readOnly
    
    (tag.aside {
      className:  if person.avatar_url then '' else 'no-avatar' 
      onClick:    @onEditPersonClick.bind(@, person.uuid)
      style:
        backgroundColor:  if person.avatar_url then 'none' else colors.colors[colors.colorIndex(personInitials)]
        backgroundImage:  if person.avatar_url then "url(#{person.avatar_url})" else "none"
    },
      (tag.figure null, personInitials) unless person.avatar_url
    )
    
    (tag.footer null,
      (tag.p { className: 'name' }, person.full_name)
      (tag.p { className: 'occupation' }, person.occupation)
    )
    
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
  
  
  onPersonUpdateDone: ->
    setTimeout ModalActions.hide
  
  
  getCloudFluxActions: ->
    'person:create:done-': @onPersonCreateDone
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
  
  
  onEditPersonClick: (key) ->
    console.log key
    ModalActions.show(PersonForm({
      attributes: PersonStore.get(key).toJSON()
      onSubmit:   @onPersonFormSubmit.bind(@, key)
    }))
  
  
  onPersonFormSubmit: (key, attributes) ->
    person = PersonStore.get(key)
    if person.uuid
      PersonActions.update(key, attributes.toJSON())
    else
      PersonActions.create(key, attributes.toJSON())
  
  
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
      className: 'editor-people'
    },
      (tag.ul {
        className: 'grid _1x3 top'
      },
      
        # People
        #
        _.map people, (person) ->
          (tag.li {
            key:        person.props.key
            className:  'cell'
          }, person)
        
        
        # Add person
        #
        (tag.li {
          className: 'cell add'
        },
          (tag.div {
            className: 'editor-person'
          },
            (tag.aside {
            },
              (tag.figure {
                onClick: @onAddPersonClick
              },
                if people.length == 0 then 'Add person' else '+'
              )
            )
          )
        ) unless @props.readOnly

      )

    )


# Exports
#
module.exports = Component
