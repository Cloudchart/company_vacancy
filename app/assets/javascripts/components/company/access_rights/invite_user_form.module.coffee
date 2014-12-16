# @cjsx React.DOM

# Imports
#
CompanyActions    = require('actions/company')
RoleMap           = require('utils/role_map')
Typeahead         = require('components/form/typeahead')
Field             = require('components/form/field')

Buttons           = require('components/form/buttons') 
StandardButton    = Buttons.StandardButton
SyncButton        = Buttons.SyncButton

CompanyStore      = require("stores/company")
TokenStore        = require("stores/token_store")
RoleStore         = require("stores/role_store")
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

  propTypes:
    uuid:                      React.PropTypes.any.isRequired
    tokenKey:                  React.PropTypes.any.isRequired
    onCurrentUsersButtonClick: React.PropTypes.func

  validateEmail: (email) ->
    errors = []

    if email == ""
      errors.push("missing")
    else if !/@/.test(email)
      errors.push("invalid")

    errors

  rolesInputs: ->
    @props.cursor.constants.get('invitable_roles').map (role) =>
      <label
        key       = {role}
        className = "role form-field-radio-2" >
        <input
          checked  =  {role is @state.role}
          name     =  "role"
          type     =  "radio"
          value    =  {role}
          onChange =  {@onRoleChange}
        />
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

  # TODO: refactor
  filterContacts: (query) ->
    userSeq     = Immutable.Seq(@state.users)
    tokenSeq    = Immutable.Seq(@state.tokens)
    queryRe     = new RegExp("(^|\\s)#{query}\\.*", 'i')
    matches     = ["email", "username", "name"]

    @props.cursor.constants.get('invitable_contacts')
      
      .filterNot (names, email) ->
        userSeq.filter((user) -> user.get('email') is email).first() or 
        tokenSeq.filter((token) -> token.getIn(['data', 'email']) is email).first()
      
      .map (names, email) ->
        [matchedBy, filteredName] = if email.match(queryRe)
          ["email", names.first()]
        else
          filteredName = names.filter((name) -> name.match(queryRe)).first()

          if filteredName
            [(if names.indexOf(filteredName) is 0 then "username" else "name"), filteredName]
          else
            []

        if matchedBy
          value:        "#{filteredName} <#{email}>"
          content:      "#{filteredName} <#{email}>"
          matchedValue: matches.indexOf(matchedBy)
        else
          null

      .valueSeq()
      .filter (item) -> item
      .sortBy (item) -> item.matchedValue
      .take(7)
      .toArray()


  emailInput: ->
    if @state.errors
      errors = _.map @state.errors.get("email"), (error) -> Errors.email[error]

    options = @filterContacts(@state.email)

    <Typeahead
      className      = "email"
      value          = {@state.email}
      options        = {options}

      onBlur         = {@onEmailBlur}
      onChange       = {@onEmailChange}
      onOptionSelect = {@onEmailChange}

      input          = { Field }
      inputProps = {
        errors:         errors
        placeholder:    "user@example.com"
      } 
    />

  onSubmit: (event) ->
    event.preventDefault()

    email = @formatEmail(@state.email)
    errors = @state.errors.get("email") || @validateEmail(email)

    if errors.length is 0
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

  componentWillReceiveProps: (nextProps) ->
    @setState(@getStateFromStores(nextProps))

  getStateFromStores: (props) ->
    roles = RoleStore.filter (role) -> role.owner_id is props.uuid and role.owner_type is 'Company'
    user_ids = _.pluck roles, 'user_id'

    company: CompanyStore.get(props.uuid)
    users: UserStore.filter (user) -> _.contains user_ids, user.uuid
    errors: Immutable.Map(TokenStore.errorsFor(props.tokenKey) or {})
    sync: TokenStore.getSync(props.tokenKey)
    tokens: TokenStore.filter (token) -> token.owner_id is props.uuid and token.owner_type is 'Company'

  getDefaultProps: ->
    onCurrentUsersButtonClick: ->
  
  getInitialState: ->
    _.extend @getStateFromStores(@props),
      email: ""
      role: @props.cursor.constants.getIn(['invitable_roles', 0])

  render: ->
    return null unless @state.company

    <div>
      <header>
        <StandardButton 
          className = "transparent"
          iconClass = "fa-angle-left"
          onClick = {@props.onCurrentUsersButtonClick}
        />
        Share <strong>{@state.company.name}</strong> {RoleMap[@state.role].header}
      </header>

      <form className="invite-user content" onSubmit={@onSubmit} >
        <fieldset className="roles">
          { @rolesInputs().toArray() }
        </fieldset>

        <footer>
          { @emailInput() }

          <SyncButton 
            className = "cc cc-wide"
            text      = "Invite"
            sync      = {@state.sync == "send"}
            onClick   = {@onSubmit} 
          />
        </footer>

      </form>
    </div>


# Exports
#
module.exports = Component
