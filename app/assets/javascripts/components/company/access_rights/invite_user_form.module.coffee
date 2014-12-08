# @cjsx React.DOM

# Imports
#
SyncButton        = require('components/company/buttons').SyncButton
CompanyActions    = require('actions/company')
RoleMap           = require('utils/role_map')
Typeahead         = require('components/form/typeahead')
Field             = require('components/form/field')
TempKVStore       = require('utils/temp_kv_store')

CompanyStore      = require("stores/company")
TokenStore        = require("stores/token_store")
UserStore         = require("stores/user_store")

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

  refreshStateFromStores: ->
    @setState @getStateFromStores()

  getStateFromStores: ->
    company:           CompanyStore.get(@props.uuid)
    users:             UserStore.all()
    errors:            Immutable.Map(TokenStore.errorsFor(@props.tokenKey) || {})
    sync:              TokenStore.getSync(@props.tokenKey)
    invitableRoles:    TempKVStore.get("invitable_roles") || []
    invitableContacts: TempKVStore.get("invitable_contacts") || {}

  rolesInputs: ->
    _.map @state.invitableRoles, (role) =>
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

  onEmailChange: (query) ->
    @setState
      email:  query
      errors: @state.errors.set("email", [])

  onEmailBlur: ->
    errors = []

    if @state.email == ""
      errors.push("missing")
    else if !/@/.test(@state.email)
      errors.push("invalid")

    @setState
      errors: @state.errors.set("email", errors)

  filterContacts: (query) ->
    _.chain(@state.invitableContacts)
      .pick((names, email) =>
        not _.find(@state.users, (user) -> user.email == email)
      )
      .map((names, email) ->
        contacts = "#{email}|#{names.join("|")}"

        if match = contacts.match(new RegExp("(?:^|\\|)(#{query}[\\w@\\.]+)", "i"))
          matchedByEmail    = match[1].toLowerCase() == email.toLowerCase()
          matchedByUsername = match[1].toLowerCase() == names[0].toLowerCase()

          name = if matchedByEmail then names[0] else match[1]

          value:   "#{name} <#{email}>"
          content: "#{name} <#{email}>"
          matchedValue:
            if matchedByEmail
              0
            else if matchedByUsername
              1
            else
              2
        else
          null
      )
      .compact()
      .sortBy("matchedValue")
      .first(7)
      .value()

  emailInput: ->
    if @state.errors
      errors = _.map @state.errors.get("email"), (error) -> Errors.email[error]

    options = @filterContacts(@state.email)

    <Typeahead
      value          = @state.email
      options        = options

      onBlur         = @onEmailBlur
      onChange       = @onEmailChange
      onOptionSelect = @onEmailChange

      input          = { Field }
      inputProps = {
        errors:         errors
        placeholder:    "user@example.com"
      } />

  onSubmit: (event) ->
    event.preventDefault()

    email = @formatEmail(@state.email)

    if !@state.errors || @state.errors.get("email").length == 0
      CompanyActions.sendInvite @props.tokenKey,
                        data:
                          email:  email
                          role:   @state.role
  
  onRoleChange: (event) ->
    @setState 
      role: event.target.value

  componentDidMount: ->
    CompanyStore.on("change", @refreshStateFromStores)
    TokenStore.on("change", @refreshStateFromStores)
    UserStore.on("change", @refreshStateFromStores)
    TempKVStore.on("invitable_roles_changed", @refreshStateFromStores)
    TempKVStore.on("invitable_contacts_changed", @refreshStateFromStores)

  componentWillUnmount: ->
    CompanyStore.off("change", @refreshStateFromStores)
    TokenStore.off("change", @refreshStateFromStores)
    UserStore.off("change", @refreshStateFromStores)
    TempKVStore.off("invitable_roles_changed", @refreshStateFromStores)
    TempKVStore.off("invitable_contacts_changed", @refreshStateFromStores)

  propTypes:
    uuid:                      React.PropTypes.any.isRequired
    tokenKey:                  React.PropTypes.any.isRequired
    onCurrentUsersButtonClick: React.PropTypes.func

  getDefaultProps: ->
    onCurrentUsersButtonClick: ->
  
  getInitialState: ->
    _.extend @getStateFromStores(),
      email: ""
      role:  TempKVStore.get("invitable_roles")[0] || null

  render: ->
    if @state.company
      <div>
        <header>
          <button className="transparent" onClick=@props.onCurrentUsersButtonClick>
            <i className="fa fa-angle-left"></i>
          </button>

          Share <strong>{@state.company.name}</strong> {RoleMap[@state.role].header} 
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
            {
              SyncButton
                className : "cc-wide"
                title     : "Invite"
                icon      : "fa-ticket"
                sync      : @state.sync == "send"
                disabled  : @state.sync
                onClick   : @onSubmit
            }
          </footer>
        </form>
      </div>
    else
      null


# Exports
#
module.exports = Component
