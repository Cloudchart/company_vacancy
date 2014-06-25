##= require ./buttons
##= require ./identity_form_commons

# Shortcuts
#
tag = React.DOM


#
# Name field
#
NameField = (value, callback, autofocus = false) ->
  (tag.label {},
    (tag.input {
      type:           'text'
      name:           'name'
      placeholder:    'Name'
      className:      'blueprint'
      autoFocus:      autofocus
      autoComplete:   'off'
      value:          value
      required:       true
      onChange:       callback
    })
  )


#
# Description field
#
DescriptionField = (value, callback) ->
  (tag.label {},
    (tag.textarea {
      name:         'description'
      placeholder:  'Description'
      className:    'blueprint'
      rows:         5
      value:        value
      onChange:     callback
    })
  )

#
# Vacancy Form
#

Vacancy = React.createClass


  mixins: [
    cc.blueprint.react.forms.IdentityFormCommons
  ]
  
  
  onNameChange: (event) ->
    @setState
      name: event.target.value


  onDescriptionChange: (event) ->
    @setState
      description: event.target.value


  render: ->
    (tag.form {
      className:  'vacancy'
      onSubmit:   @onSubmit
    },
      (NameField          @state.name,          @onNameChange, @props.model.is_new_record())
      (DescriptionField   @state.description,   @onDescriptionChange)
      (cc.blueprint.react.forms.Buttons { model: @props.model, onDelete: @onDelete })
    )

#
#
#

_.extend @cc.blueprint.react.forms,
  Vacancy: Vacancy
