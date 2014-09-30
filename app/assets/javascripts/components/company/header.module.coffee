# Imports
#
tag = React.DOM


CompanyActions  = require('actions/company')
AutoSizingInput = require('components/form/autosizing_input')


# Main
#
Component = React.createClass


  update: ->
    attributes =
      name:             @state.name
      description:      @state.description

    CompanyActions.update(@props.key, attributes)
  
  
  updateLogotype: (file) ->
    CompanyActions.update(@props.key, { logotype: file })
  
  
  removeLogotype: ->
    CompanyActions.update(@props.key, { logotype_url: null, remove_logotype: true })


  onShareLinkClick: (event) ->
    event.preventDefault()
  
  
  isValid: ->
    @state.name.length > 0
  
  
  rollback: ->
    if @state.name.length == 0
      @setState({ name: @props.name })


  onFieldBlur: ->
    if @isValid() then @update() else @rollback()


  onFieldChange: (name, event) ->
    state       = {}
    state[name] = event.target.value
    @setState(state)
  
  
  onLogotypeChange: (event) ->
    file = event.target.files[0]
    @setState({ logotype_url: URL.createObjectURL(file) })
    @updateLogotype(file)
  
  
  onFieldKeyUp: (event) ->
    event.target.blur() if event.key == 'Enter'
  
  
  componentWillReceiveProps: (nextProps) ->
    URL.revokeObjectURL(@state.logotype_url)
    @setState(@getStateFromProps(nextProps))


  getStateFromProps: (props) ->
    logotype_url:     props.logotype_url
    name:             props.name
    description:      props.description


  getInitialState: ->
    @getStateFromProps(@props)


  render: ->
    (tag.header {
    },
    
      # Logo
      #
      (tag.aside {
        className: 'logo'
        style:
          backgroundImage: if @state.logotype_url then "url(#{@state.logotype_url})" else "none"
      },
      
        (tag.label {
        },

          (tag.div {
            className: 'placeholder'
          },
            (tag.i { className: 'fa fa-picture-o' })
            (tag.span null, 'Tap to add logo')
          ) unless @state.logotype_url
          
          (tag.input {
            type:     'file'
            onChange: @onLogotypeChange
          })
        )

        (tag.button {
          className:  'remove'
          onClick:    @removeLogotype
        },
          (tag.i { className: 'fa fa-times' })
        ) if @state.logotype_url

      )
      
      # Name
      #
      (tag.label {
        className: 'name'
      },
        (AutoSizingInput {
          value:        @state.name
          onBlur:       @onFieldBlur
          onChange:     @onFieldChange.bind(@, 'name')
          onKeyUp:      @onFieldKeyUp
          placeholder:  'Company name'
        })

        (tag.a {
          className:  'share-link'
          href:       ''
          onClick:    @onShareLinkClick
        },
          (tag.i { className: 'fa fa-share' })
        )
      )
      
      # Description
      #
      (tag.label {
        className: 'description'
      },
        (AutoSizingInput {
          value:        @state.description
          onBlur:       @onFieldBlur
          onChange:     @onFieldChange.bind(@, 'description')
          onKeyUp:      @onFieldKeyUp
          placeholder:  'Company description'
        })
      )
    
    )


# Exports
#
module.exports = Component
