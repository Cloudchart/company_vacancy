# Imports
# 
tag = React.DOM

# SomeComponent = require('')

Header = ->
  (tag.header {
  },
    (tag.input {
      autoFocus:    true
      onChange:     @onFieldChange.bind(@, 'title')
      value:        @state.attributes.get('title')
      placeholder:  "Post Title"
    })
  )

Fieldset = ->
  (tag.fieldset {
  },
    Field.apply(@,  ['published_at', 'fa-calendar-o', moment().format('lll')])
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

# Main
# 
Component = React.createClass

  isValid: ->
    @state.attributes.get('title').length > 0 #and @state.attributes.get('published_at')


  onSubmit: (event) ->
    event.preventDefault()
    @props.onSubmit(@state.attributes) if _.isFunction(@props.onSubmit)


  onFieldChange: (name, value) ->
    @setState({ attributes: @state.attributes.set(name, event.target.value) })


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
          disabled:   !@isValid()
          type:       'submit'
        },
          if @state.attributes.get('uuid') then "Update" else "Create"
          (tag.i { className: 'fa fa-check' })
        )
      )
      
    )

# Exports
# 
module.exports = Component

