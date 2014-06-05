@cc                   ||= {}
@cc.blueprint         ||= {}
@cc.blueprint.react   ||= {}

#
#
#

# Restructure
#
tag = React.DOM


# First name input
#
first_name_field = (value, callback) ->
  (tag.label null,
    (tag.input {
      type:           'text'
      name:           'first_name'
      value:          value
      autoFocus:      true
      autoComplete:   'off'
      required:       true
      placeholder:    'Name'
      className:      'blueprint'
      onChange:       callback
    })
  )


# Last name input
#
last_name_field = (value, callback) ->
  (tag.label null,
    (tag.input {
      type:           'text'
      name:           'last_name'
      value:          value
      autoComplete:   'off'
      required:       true
      placeholder:    'Surname'
      className:      'blueprint'
      onChange:       callback
    })
  )


# Occupation field
#
occupation_field = (value, callback) ->
  (tag.label null,
    (tag.textarea {
      name:           'occupation'
      rows:           2
      placeholder:    'Occupation'
      className:      'blueprint'
      value:          value
      onChange:       callback
    })
  )


# Person form buttoms
#
person_form_buttons = (model, onDeleteCallback) ->
  (tag.nav {
    className: 'buttons'
  }, [
    if model.is_persisted()
      (tag.a {
        href:       '#'
        className:  'alert blueprint-button'
        onClick:    onDeleteCallback
      }, [
        (tag.i { className: 'fa fa-times' })
        " Delete"
      ])
    (tag.div { className: 'spacer' })
    (tag.button { className: 'blueprint' }, [
      (tag.i { className: 'fa fa-check' })
      [" Create", " Update"][~~model.is_persisted()]
    ])
  ])

#
#
#

person_form = React.createClass


  getInitialState: ->
    @props.model.attributes


  onChange: (event) ->
    attributes = {}
    attributes[event.target.name] = event.target.value
    @setState attributes
  
  
  onSubmit: (event) ->
    event.preventDefault()
    
    # Check requireds
    form    = @getDOMNode()
    inputs  = form.querySelectorAll('[required]')
      
    if input = _.find(inputs, (input) -> !input.value)
      input.focus()
      return false
    
    if @props.model.is_persisted()
      # Update model
      @props.model.set_attributes(@state)
    else
      @props.model.constructor.create(@state)
      $.pass

    cc.blueprint.dispatcher.sync()
    
    cc.ui.modal.close()
  
  
  onDelete: (event) ->
    event.preventDefault()

    return if event.currentTarget.hasAttribute('disabled')

    # Destroy model
    delete @props.model.constructor.instances[@props.model.uuid]
    cc.blueprint.dispatcher.sync()
    
    cc.ui.modal.close()
  

  render: ->
    (tag.form {
      className:  'person'
      onSubmit:   @onSubmit
    }, [
      (tag.aside { className: 'avatar' },
        (tag.i { className: 'fa fa-users' })
      )
      (tag.section { className: 'name' }, [
        first_name_field(@state.first_name, @onChange)
        last_name_field(@state.last_name, @onChange)
      ])
      occupation_field(@state.occupation, @onChange)
      person_form_buttons(@props.model, @onDelete)
    ])


#
#
#

_.extend @cc.blueprint.react,
  person_form: person_form
