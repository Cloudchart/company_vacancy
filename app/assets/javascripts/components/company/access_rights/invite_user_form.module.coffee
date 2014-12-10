# @cjsx React.DOM

# Imports
#
CompanyActions    = require('actions/company')
RoleMap           = require('utils/role_map')
Typeahead         = require('components/form/typeahead')
Field             = require('components/form/field')
TempKVStore       = require('utils/temp_kv_store')

Buttons           = require('components/form/buttons') 
StandardButton    = Buttons.StandardButton
SyncButton        = Buttons.SyncButton

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
    tokens:            TokenStore.filter (token) => token.owner_id == @props.uuid && token.owner_type == "Company"
    invitableRoles:    TempKVStore.get("invitable_roles") || []
    invitableContacts: TempKVStore.get("invitable_contacts") || {}

  validateEmail: (email) ->
    errors = []

    if email == ""
      errors.push("missing")
    else if !/@/.test(email)
      errors.push("invalid")

    errors

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
    @setState
      errors: @state.errors.set("email", @validateEmail(@state.email))

  filterContacts: (query) ->
    _.chain(@state.invitableContacts)
      .pick((names, email) =>
        not _.find(@state.users, (user) -> user.email == email) &&
        not _.find(@state.tokens, (token) -> token.data.email == email)
      )
      .map((names, email) ->
        re = new RegExp("(^|\\s)#{query}\\.*", "i")
        matchedBy = null

        if email.match(re)
          filteredName = names[0]
          matchedBy = "email"
        else
          _.each names, (name, index) ->
            if name.match(re)
              filteredName = name
              matchedBy = if (index == 0) then "username" else "name"

        if matchedBy
          value:   "#{filteredName} <#{email}>"
          content: "#{filteredName} <#{email}>"
          matchedValue:
            if matchedBy == "email"
              0
            else if matchedBy == "username"
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
      className      = "email"
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

    errors = @state.errors.get("email") || @validateEmail(email)

    if errors.length == 0
      CompanyActions.sendInvite @props.tokenKey,
                        data:
                          email:  email
                          role:   @state.role
    else if !@state.errors.get("email")
      @setState
        errors: @state.errors.set("email", errors)
  
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
          <StandardButton 
            className="transparent"
            iconClass="fa-angle-left"
            onClick=@props.onCurrentUsersButtonClick />
          Share <strong>{@state.company.name}</strong> {RoleMap[@state.role].header}
        </header>

        <form className = "invite-user content"
              onSubmit  = @onSubmit >
        
          <fieldset className="roles">
            { @rolesInputs() }
          </fieldset>

          <footer>
            { @emailInput() }

            <SyncButton 
              className = "cc cc-wide"
              text      = "Invite"
              sync      = {@state.sync == "send"}
              onClick   = @onSubmit />
          </footer>
        </form>
      </div>
    else
      null


# Exports
#
module.exports = Component
