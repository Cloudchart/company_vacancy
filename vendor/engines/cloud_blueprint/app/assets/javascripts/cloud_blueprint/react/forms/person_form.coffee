##= require ./buttons

# Shortcuts
#
tag = React.DOM


#
# First name field
#
FirstNameField = (value, callback) ->
  (tag.label {},
    (tag.input {
      type:           'text'
      name:           'first_name'
      placeholder:    'Name'
      className:      'blueprint'
      autoFocus:      true
      autoComplete:   'off'
      value:          value
      required:       true
      onChange:       callback
    })
  )


#
# Last name field
#
LastNameField = (value, callback) ->
  (tag.label {},
    (tag.input {
      type:           'text'
      name:           'last_name'
      placeholder:    'Surname'
      className:      'blueprint'
      autoComplete:   'off'
      value:          value
      required:       true
      onChange:       callback
    })
  )


#
# Occupation field
#
OccupationField = (value, callback) ->
  (tag.label {},
    (tag.textarea {
      name:         'occupation'
      placeholder:  'Occupation'
      className:    'blueprint'
      rows:         2
      value:        value
      onChange:     callback
    })
  )

#
# Person Form
#

Person = React.createClass


  getInitialState: ->
    @props.model.attributes

  
  onSubmit: (event) ->
    event.preventDefault()
    

    if missing_field = _.find(@getDOMNode().querySelectorAll('[required]'), (field) -> !field.value)
      return missing_field.focus() and false
    
    
    if @props.model.is_persisted()
      @props.model.update(@state).save()
    else
      @props.model.constructor.create(@state).save()


    Arbiter.publish('loaded')
    cc.ui.modal.close()
  
  
  onDelete: (event) ->
    event.preventDefault()
    @props.model.destroy().save()
    Arbiter.publish('loaded')
    cc.ui.modal.close()
  
  
  onFirstNameChange: (event) ->
    @setState
      first_name: event.target.value


  onLastNameChange: (event) ->
    @setState
      last_name: event.target.value
  
  
  onOccupationChange: (event) ->
    @setState
      occupation: event.target.value


  render: ->
    (tag.form {
      className:  'person'
      onSubmit:   @onSubmit
    },
      (tag.aside { className: 'avatar' },
        (tag.i { className: 'fa fa-users' })
      )
      (tag.section { className: 'name' },
        (FirstNameField   @state.first_name,  @onFirstNameChange)
        (LastNameField    @state.last_name,   @onLastNameChange)
      )
      (OccupationField @state.occupation, @onOccupationChange)
      (cc.blueprint.react.forms.Buttons { model: @props.model, onDelete: @onDelete })
    )

#
#
#

_.extend @cc.blueprint.react.forms,
  Person: Person
