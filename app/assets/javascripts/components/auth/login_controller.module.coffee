# @cjsx React.DOM

LoginForm   = require("components/auth/login_form")

ModalStack  = require("components/modal_stack")

InviteForm  = require("components/auth/invite_form")

email_re = /.+@.+\..+/i

Errors =
  email:
    missing:  "Enter email for login, please"
  password:
    missing:  "Enter password for login, please"

getErrorMessages = (errorsLists) ->
  errors = _.mapValues errorsLists, (errors, attributeName) ->
    _.map errors, (errorName) ->
      Errors[attributeName][errorName] || errorName

  errors


validate = (attributes) ->
  errors =
    email:     []
    password:  []

  if (!attributes.email || attributes.email == '')
    errors.email.push 'missing'

  if (!attributes.password || attributes.password == '')
    errors.password.push 'missing'

  errors


LoginController = React.createClass

  # Component Specifications
  # 
  getInitialState: ->
    errors:     {}
    isSyncing:  false


  # Helpers
  #
  isPasswordInvalid: (errors) ->
    errors.password && errors.password.length > 0

  isValid: (errors) ->
    _.all(_.values(errors), (error) -> error.length == 0)

  getDOMAttributes: ->
    loginForm = this.refs.loginForm
    emailValue = loginForm.refs.email.refs.input.getDOMNode().value
    passwordValue = loginForm.refs.password.refs.input.getDOMNode().value

    attributes =
      email: emailValue
      password: passwordValue    

  requestLogin: ->
    attributes = @getDOMAttributes()

    if @isValid(@state.errors)
      errors = validate(attributes)

      if @isValid(errors)
        @setState(isSyncing: true)

        $.ajax
          url:        '/login'
          type:       'POST'
          dataType:   'json'
          data:
            email:      attributes.email
            password:   attributes.password
        .done @handleRequestLoginDone
        .fail @handleRequestLoginFail
      else
        @setState(attributes: attributes, errors: errors)

  requestReset: ->
    $.ajax
      url:      '/profile/password/forgot'
      type:     'POST'
      dataType: 'json'
      data:
        email:  @state.attributes.email
    .done @handleResetPasswordRequestDone

  showInviteModal: (event) ->
    event.preventDefault()

    ModalStack.show(
      <InviteForm 
        invite    = { @state.invite }
        full_name = { @state.full_name }
        email     = { @state.email } />
    )


  # Handlers
  #
  handleRequestLoginDone: (json) ->
    location.href = json.previous_path    
  
  handleRequestLoginFail: (xhr) ->
    @setState(isSyncing: false)
    errors = xhr.responseJSON.errors

    @setState
      attributes: @getDOMAttributes()
      errors: errors
      isResetShown: @isPasswordInvalid(errors)

  handleResetPasswordRequestDone: (json) ->
    console.log 'handleResetPasswordRequestDone'

  handleFormChange: (name, value) ->
    errors = {}

    @setState
      isResetShown: false
      errors:       errors


  render: ->
    <LoginForm
      errors       = { getErrorMessages(@state.errors) }
      isResetShown = { @state.isResetShown }
      isSyncing    = { @state.isSyncing }
      onChange     = { @handleFormChange }
      onInvite     = { @showInviteModal }
      onReset      = { @requestReset }
      onSubmit     = { @requestLogin }
      ref          = { "loginForm" } />

module.exports = LoginController