#
# Shortcuts
#
tag = React.DOM


#
# Common
#


# Submit button
#
SubmitButton = (props, state) ->
  (tag.button { className: 'blueprint' },
    (tag.i { className: 'fa fa-check' })
    " "
    ["Create", "Update"][~~props.model.is_persisted()]
  )


# Delete button
#
DeleteButton = (props, state, onClick) ->
  (tag.a {
    href:       ''
    className:  'blueprint-button alert'
    onClick:    onClick
  },
    (tag.i { className: 'fa fa-times' })
    " Delete"
  )


# Unlink button
#
UnlinkButton = (props, state, onClick) ->
  (tag.a {
    href:       ''
    className:  'blueprint-button alert'
    onClick:    onClick
  },
    (tag.i { className: 'fa fa-times' })
    " Remove"
  )


#
# Person
#

# Person first name
#
PersonFullName = (props, state, onChange) ->
  (tag.label {},
    (tag.input {
      type:         'text'
      name:         'full_name'
      placeholder:  'Name Surname'
      className:    'blueprint full-name'
      autoComplete: 'off'
      autoFocus:    props.model.is_new_record()
      value:        state.full_name
      onChange:     onChange
      required:     true
    })
  )
    

# Person first name
#
PersonLastName = (props, state, onChange) ->
  (tag.label {},
    (tag.input {
      type:           'text'
      name:           'last_name'
      placeholder:    'Surname'
      className:      'blueprint last-name'
      autoComplete:   'off'
      value:          state.last_name
      onChange:       onChange
      required:       true
    })
  )


# Person occupation
#
PersonOccupation = (props, state, onChange) ->
  (tag.label {},
    (tag.textarea {
      name:         'occupation'
      placeholder:  'Occupation'
      className:    'blueprint occupation'
      value:        state.occupation
      onChange:     onChange
      rows:         5
    })
  )


# Person form
#
PersonForm = React.createClass


  getInitialState: ->
    data = _.extend({}, @props.model.attributes)
    data.full_name = [@props.model.first_name, @props.model.last_name].filter((part) -> part).join(' ')
    data
    


  onFullNameChange: (event) ->
    @setState
      full_name: event.target.value
  

  onLastNameChange: (event) ->
    @setState
      last_name: event.target.value


  onOccupationChange: (event) ->
    @setState
      occupation: event.target.value


  render: ->
    (tag.form {
      className:  'person'
      onSubmit:   @props.onSubmit
    },
      (tag.section { className: 'fields' },
        (tag.div { className: 'name' },
          (cc.blueprint.react.Identity.PersonIcon(@state))
          (PersonFullName  @props, @state, @onFullNameChange)
        )
        (PersonOccupation @props, @state, @onOccupationChange)
      )
      @props.children
    )


#
# Vacancy
#

# Vacancy name
#
VacancyName = (props, state, onChange) ->
  (tag.label {},
    (tag.input {
      type:         'text'
      name:         'name'
      placeholder:  'Name'
      className:    'blueprint name'
      autoComplete: 'off'
      autoFocus:    props.model.is_new_record()
      value:        state.name
      onChange:     onChange
      required:     true
    })
  )


# Person occupation
#
VacancyDescription = (props, state, onChange) ->
  (tag.label {},
    (tag.textarea {
      name:         'description'
      placeholder:  'Description'
      className:    'blueprint description'
      value:        state.description
      onChange:     onChange
      rows:         5
    })
  )


# Vacancy form
#

VacancyForm = React.createClass
  

  getInitialState: ->
    @props.model.attributes


  onNameChange: (event) ->
    @setState
      name: event.target.value


  onDescriptionChange: (event) ->
    @setState
      description: event.target.value


  render: ->
    (tag.form {
      className:  'vacancy'
      onSubmit:   @props.onSubmit
    },
      (tag.section { className: 'fields' },
        (tag.div { className: 'name' },
          (tag.aside { className: 'avatar' },
            (tag.i { className: 'fa fa-briefcase' })
          )
          (VacancyName @props, @state, @onNameChange)
        )
        (VacancyDescription @props, @state, @onDescriptionChange)
      )
      @props.children
    )


#
# Renders
#
renders =
  Person:   PersonForm
  Vacancy:  VacancyForm

#
# Identity Form
#

Identity = React.createClass


  missingField: ->
    _.find(@getDOMNode().querySelectorAll('[required]'), (field) -> !field.value)


  onSubmit: (event) ->
    event.preventDefault()
    
    return missing_field.focus() and false if missing_field = @missingField()
    
    attributes = @refs.form.state
  
    if @props.model.is_persisted()
      @props.model.update(attributes).save()
    else
      @props.model.constructor.create(attributes).save()
    
    cc.blueprint.react.modal.hide()
  
  
  onDelete: (event) ->
    event.preventDefault()

    @props.model.destroy().save()

    cc.blueprint.react.modal.hide()
  
  
  onUnlink: (event) ->
    event.preventDefault()

    identity = _.find cc.blueprint.models.Identity.instances, (instance) =>
      instance.node_id        == @props.node_uuid                   and
      instance.identity_id    == @props.model.uuid                  and
      instance.identity_type  == @props.model.constructor.className
    
    identity.destroy().save()

    cc.blueprint.react.modal.close()


  render: ->
    props = _.extend({}, @props,
      ref:      'form'
      onSubmit: @onSubmit
    )

    renders[@props.model.constructor.className](props,
      (tag.section { className: 'controls' },
        (DeleteButton @props, @state, @onDelete) if @props.model.can_be_deleted()
        (UnlinkButton @props, @state, @onUnlink) if @props.node_uuid
        (tag.div {})
        (SubmitButton @props, @state)
      )
    )


# Spacer tag
#
SpacerComponent = ->
  (tag.div { className: 'spacer' })


# Delete button
#
DeleteButtonComponent = (model, callback) ->
  (tag.button {
    type:       'button'
    className:  'orgpad alert'
    onClick:    callback
  },
    "Delete"
    (tag.i { className: 'fa fa-times' })
  )


# Submit button
#
SubmitButtonComponent = (model, callback) ->
  (tag.button {
    type:       'submit'
    className:  'orgpad'
    onClick:    callback
  },
    "Create"  unless model.is_persisted()
    "Update"  if model.is_persisted()
    (tag.i { className: 'fa fa-check' })
  )


#
# Availability
#

_.extend @cc.blueprint.react.forms,
  Identity: Identity
