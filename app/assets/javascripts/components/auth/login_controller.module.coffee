# @cjsx React.DOM

LoginForm   = require("components/auth/login_form")

ModalStack  = require("components/modal_stack")

ResetSplash = require("react_components/modals/reset_splash")
InviteForm  = require("react_components/modals/invite_form")

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
    attributes: {}
    errors:     {}
    isSyncing:  false


  # Helpers
  #
  isPasswordInvalid: (errors) ->
    errors.password && errors.password.length > 0

  isValid: (errors) ->
    _.all(_.values(errors), (error) -> error.length == 0)

  requestLogin: ->
    if @isValid(@state.errors)
      errors = validate(@state.attributes)

      if @isValid(errors)
        @setState(isSyncing: true)

        $.ajax
          url:        '/login'
          type:       'POST'
          dataType:   'json'
          data:
            email:      @state.attributes.email
            password:   @state.attributes.password
        .done @handleRequestLoginDone
        .fail @handleRequestLoginFail
      else
        @setState(errors: errors)

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
      errors: errors
      isResetShown: @isPasswordInvalid(errors)

  handleResetPasswordRequestDone: (json) ->
    ModalStack.show(<ResetSplash />)

  handleFormChange: (name, value) ->
    attributes = @state.attributes
    attributes[name] = value
    errors = {}

    @setState
      isResetShown: false
      attributes:   attributes
      errors:       errors


  render: ->
    <LoginForm
      attributes   = { @state.attributes }
      errors       = { getErrorMessages(@state.errors) }
      isResetShown = { @state.isResetShown }
      isSyncing    = { @state.isSyncing }
      onChange     = { @handleFormChange }
      onInvite     = { @showInviteModal }
      onReset      = { @requestReset }
      onSubmit     = { @requestLogin } />

module.exports = LoginController