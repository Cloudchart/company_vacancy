# @cjsx React.DOM

# Imports
#
tag = React.DOM


SyncButton        = require('components/company/buttons').SyncButton
Actions           = require('actions/company')
RoleMap           = require('utils/role_map')
Typeahead         = require('components/form/typeahead')
Field             = require('components/form/field')

cx = React.addons.classSet

# Get State from Props
#
getStateFromProps = (props) ->
  role:   props.token.data.role   || props.invitable_roles[0]
  email:  props.token.data.email  || ''
  errors: new Immutable.Map({})

# Errors
#
Errors =
  email:
    missing: "Enter email, please!"
    invalid:  "You must enter a valid email."
    taken:    "User with this email was already invited to company."

# Main
#
Component = React.createClass

  rolesInputs: ->
    _.map @props.invitable_roles, (role) =>
      <label
        key       = role
        className = "role form-field-radio-2" >
        <input
          checked  =  { role == @state.role }
          name     =  "role"
          type     =  "radio"
          value    =  role
          onChange =  @onRoleChange />
        <div className="title">
          { RoleMap[role].description }
          <div className="hint">
            { RoleMap[role].hint }
          </div>
        </div>
      </label>

  formatEmail: (email) ->
    if match = email.match(/.+\<(.+)\>/)
      email = match[1]

    email

  onEmailChange: (value) ->
    email = @formatEmail(value)

    @setState
      email: email
      errors: @state.errors.set("email", [])

  onEmailBlur: ->
    errors = []

    if @state.email == ""
      errors.push("missing")
    else if !/@/.test(@state.email)
      errors.push("invalid")

    @setState
      errors: @state.errors.set("email", errors)

  emailInput: ->
    errors = _.map @state.errors.get('email'), (error) ->
      Errors.email[error]

    getValue = (option) -> option.email

    filterOption = (option, query) =>
      query = query.trim().toLowerCase()

      option.full_name.toLowerCase().indexOf(query) == 0 ||
      option.email.toLowerCase().indexOf(query) == 0

    renderOption = (option) ->
      "#{option.full_name} <#{option.email}>"

    <Typeahead
      value          = @state.email
      maxOptions     = 7
      options        = @props.emails

      onBlur         = @onEmailBlur
      onChange       = @onEmailChange
      onOptionSelect = @onEmailChange

      input          = { Field }
      inputProps = {
        type:           "email"
        errors:         errors
        placeholder:    "user@example.com"
      } 

      getOptionValue = { getValue }
      filterOption   = { filterOption }
      renderOption   = { renderOption } />

  formHeader: ->
    RoleMap[@state.role].header

  onSubmit: (event) ->
    event.preventDefault()

    Actions.sendInvite(@props.key, {
      data:
        email:  @state.email
        role:   @state.role
    })
  
  onRoleChange: (event) ->
    @setState({ role: event.target.value })

  componentWillReceiveProps: (newProps) ->
    @setState
      errors: new Immutable.Map(newProps.errors)
  
  getInitialState: ->
    state = getStateFromProps(@props)
    state

  isValid: ->
    errors = @state.errors.get("email")
    errors ||= []

    errors.length == 0

  render: ->
    <div>
      <header>
        <a href = "" onClick = @props.onCurrentUsersButtonClick>
          <i className="fa fa-angle-left"></i>
        </a>

        Share <strong>{@props.company.name}</strong> {@formHeader()} 
      </header>

      <form className = 'invite-user'
            onSubmit  = @onSubmit >
      
        <fieldset className='roles'>
          { @rolesInputs() }
        </fieldset>
        
        <fieldset className='email'>
          { @emailInput() }
        </fieldset>
      
        <footer>
          <SyncButton
            className = 'cc-wide'
            title     = 'Invite'
            icon      = 'fa-ticket'
            sync      = { @props.sync == 'send-invite' }
            disabled  = { @props.sync || !@isValid() }
            onClick   = @onSubmit />
        </footer>
      </form>
    </div>


# Exports
#
module.exports = Component
