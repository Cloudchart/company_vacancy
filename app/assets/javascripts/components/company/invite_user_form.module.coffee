# Imports
#
tag = React.DOM


Buttons     = require('components/company/buttons')
Actions     = require('actions/company')
roleMaps    = require('utils/role_maps')

cx = React.addons.classSet

# Get State from Props
#
getStateFromProps = (props) ->
  role:   props.token.data.role   || props.roles[0]
  email:  props.token.data.email  || ''


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
        className:  'role form-field-radio-2'
      },
        (tag.input {
          checked:    role == @state.role
          name:       'role'
          type:       'radio'
          value:      role
          onChange:   @onRoleChange
        })
        (tag.div {className: 'title'},
          roleMaps.RoleDescriptionMap[role]
          (tag.div {
            className: 'hint'
          },
            'Company HR managers or managing partners usually need access to editing'
          )
        )
      )
  

  emailInput: ->
    errorTag = if @props.errors && errors = @props.errors["email"]
      (tag.span {className: "error"},
        Errors.email[errors[0]]
      )

    (tag.label {
      className: cx({ "form-field-2": true, invalid: @props.errors })
    },
      (tag.span { className: "input" },
        (tag.input {
          autoComplete:   'off'
          autoFocus:      true
          placeholder:    'user@example.com'
          value:          @state.email
          onChange:       @onEmailChange
        })
      )
      errorTag
    )


  onSubmit: (event) ->
    event.preventDefault()

    Actions.sendInvite(@props.key, {
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
        (Buttons.SyncButton {
          className: 'cc-wide'
          title:     'Invite'
          icon:      'fa-ticket'
          sync:      @props.sync == 'send-invite'
          disabled:  @props.sync
          onClick:   @onSubmit
        })
      )
    
    )


# Exports
#
module.exports = Component
