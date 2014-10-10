# Imports
#
tag = React.DOM


CompanyActions  = require('actions/company')
AutoSizingInput = require('components/form/autosizing_input')


# Main
#
Component = React.createClass


  update: ->
    return if @props.readOnly

    attributes =
      name:             @state.name
      description:      @state.description

    CompanyActions.update(@props.key, attributes)
  
  
  updateLogotype: (file) ->
    return if @props.readOnly

    CompanyActions.update(@props.key, { logotype: file })
  
  
  removeLogotype: ->
    return if @props.readOnly

    CompanyActions.update(@props.key, { logotype_url: null, remove_logotype: true })


  onShareLinkClick: (event) ->
    event.preventDefault()
  
  
  isValid: ->
    @state.name.length > 0
  
  
  rollback: ->
    if @state.name.length == 0
      @setState({ name: @props.name })


  onFollowClick: ->
    console.log 'onFollowClick'

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
        ) unless @props.readOnly

        (tag.button {
          className:  'remove'
          onClick:    @removeLogotype
        },
          (tag.i { className: 'fa fa-times' })
        ) unless @props.readOnly if @state.logotype_url

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
          readOnly:     @props.readOnly
        })

        (tag.a {
          className:  'share-link'
          href:       ''
          onClick:    @onShareLinkClick
        },
          (tag.i { className: 'fa fa-share' })
        ) unless @props.readOnly
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
          readOnly:     @props.readOnly
        })
      ) if @state.description or !@props.readOnly

      console.log @props.can_follow
      (tag.label {},
        (tag.button { 
          className: 'orgpad'
          onClick: @onFollowClick
        },
          'Follow'
        )
      ) if @props.readOnly and @props.can_follow
    
    )


# Exports
#
module.exports = Component
