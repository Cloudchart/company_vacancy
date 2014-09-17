# Imports
#
tag = React.DOM

Buttons       = require('components/company/buttons')
TokenActions  = require('actions/token_actions')


# Get State from Props
#
getStateFromProps = (props) ->
  role:   props.token.get('role')   || props.roles[0]
  email:  props.token.get('email')  || ''


# Errors
#
Errors =
  email:
    missing:  'Enter email, please!'
    taken:    'User with this email already invited to company.'


# Main
#
Component = React.createClass


  rolesInputs: ->
    _.map @props.roles, (role) =>
      (tag.label {
        key:        role
        className:  'role'
      },
        (tag.input {
          checked:    role == @state.role
          name:       'role'
          type:       'radio'
          value:      role
          onChange:   @onRoleChange
        })
        (tag.span {},
          role.toUpperCase()
          (tag.i {
            className: 'hint'
          },
            'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
          )
        )
      )
  

  emailInput: ->
    (tag.label {
      className: 'email'
    },
      (tag.span {},
        (tag.input {
          autoComplete:   'off'
          autoFocus:      true
          placeholder:    'user@example.com'
          value:          @state.email
          onChange:       @onEmailChange
        })
      
        if @props.errors and errors = @props.errors.get('email')
          (tag.i {
            className: 'error'
          },
            Errors.email[errors.get(0)]
          )
      )
    )


  onSubmit: (event) ->
    event.preventDefault()
    TokenActions.createCompanyInvite(@props.key, @props.company.uuid, {
      data:
        email:  @state.email
        role:   @state.role
    })
  
  
  onRoleChange: (event) ->
    @setState({ role: event.target.value })
  
  
  onEmailChange: (event) ->
    @setState({ email: event.target.value })
  
  
  getInitialState: ->
    state = getStateFromProps(@props)
    state


  render: ->
    (tag.form {
      className:  'invite-user'
      onSubmit:   @onSubmit
    },
    
      # Header
      #
      (tag.header {},
        "You're about to share "
        (tag.strong {}, @props.company.name)
        " company and chart"
      )
    
      # Fieldset / Roles
      #
      (tag.fieldset {
        className: 'roles'
      },
      
        # Roles inputs
        #
        @rolesInputs()
      
      )
      
      # Fieldset / Email
      #
      (tag.fieldset {
        className: 'email'
      },
      
        # Email input
        #
        @emailInput()
      
      )
    
      # Footer / Button
      #
      (tag.footer null,
        (Buttons.SendInviteButton {
          type:     'button'
          onClick:  @onSendInviteButtonClick
        })
      )
    
    )


# Exports
#
module.exports = Component
