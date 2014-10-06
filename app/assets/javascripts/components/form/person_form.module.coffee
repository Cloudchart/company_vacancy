# Imports
#
tag = React.DOM


Header = ->
  (tag.header {
  },
    (tag.input {
      autoFocus:    true
      onChange:     @onFieldChange.bind(@, 'full_name')
      value:        @state.attributes.get('full_name')
      placeholder:  "Name Surname"
    })
  )


Fieldset = ->
  now = moment().format('ll')
  (tag.fieldset {
  },
    Field.apply(@,  ['email',          'fa-envelope-o',    'user@example.com'])
    Field.apply(@,  ['occupation',     'fa-institution',   'Occupation'])
    Field.apply(@,  ['phone',          'fa-mobile',        'Mobile phone'])
    Field.apply(@,  ['int_phone',      'fa-phone',         'Office phone'])
    Field.apply(@,  ['skype',          'fa-skype',         'Skype name'])
    Field.apply(@,  ['birthday',       'fa-birthday-cake', now])
    Field.apply(@,  ['hired_on',       'fa-sign-in',       now])
    Field.apply(@,  ['fired_on',       'fa-sign-out',      now])
    Field.apply(@,  ['salary',         'fa-money',         '0.0'])
    Field.apply(@,  ['stock_options',  'fa-bar-chart',     '0.0'])
    Text.apply(@,   ['bio',            'fa-file-text-o',   'Bio'])
  )


Field = (name, icon, placeholder) ->
  (tag.label {
    className: name
  },
    (tag.i { className: "fa #{icon}" })
    (tag.input {
      value:        @state.attributes.get(name)
      onChange:     @onFieldChange.bind(@, name)
      placeholder:  placeholder
    })
  )


Text = (name, icon, placeholder) ->
  (tag.label {
    className: name
  },
    (tag.i { className: "fa #{icon}" })
    (tag.textarea {
      value:        @state.attributes.get(name)
      onChange:     @onFieldChange.bind(@, name)
      placeholder:  placeholder
    })
  )


# Main
#
Component = React.createClass


  onFieldChange: (name, value) ->
    @setState({ attributes: @state.attributes.set(name, event.target.value) })
  
  
  onSubmit: (event) ->
    event.preventDefault()
    @props.onSubmit(@state.attributes) if _.isFunction(@props.onSubmit)
  
  
  componentWillReceiveProps: (nextProps) ->
    @setState({ attributes: Immutable.fromJS(nextProps.attributes) }) if nextProps.attributes


  getInitialState: ->
    attributes: Immutable.fromJS(@props.attributes)


  render: ->
    (tag.form {
      onSubmit:   @onSubmit
      className:  'person-2'
    },
      
      # Header
      #
      Header.apply(@)
      
      # 
      #
      (tag.section {
      },
      
        # Avatar
        #
        (tag.aside {
          className: 'avatar'
        })
        
        # Fields
        #
        Fieldset.apply(@)
      
      )
      
      # Footer
      #
      (tag.footer {
      },

        # Spacer
        #
        (tag.div { className: 'spacer' })
      
        # Submit
        #
        (tag.button {
          className:  'cc'
          disabled:   true
          type:       'submit'
        },
          "Create"
          (tag.i { className: 'fa fa-check' })
        )
      )
      
    )


# Exports
#
module.exports = Component
