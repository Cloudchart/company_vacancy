# @cjsx React.DOM

LoginForm = require('components/auth/login_form')

email_re = /.+@.+\..+/i

Errors =
  email:
    missing:  "Enter email, please"
    invalid:  "There are no users with such an email"
  password:
    missing:  "Enter password, please"
    invalid:  "The password is wrong"

getErrorMessages = (errorsLists) ->
  errors = _.mapValues errorsLists, (errors, attributeName) ->
    _.map errors, (errorName) ->
      Errors[attributeName][errorName]

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
    
    component = cc.require("react/modals/invite-form")
    
    event = new CustomEvent 'modal:push',
      detail:
        component: (component {
          invite: @state.invite
          full_name: @state.full_name
          email: @state.email
        })
    
    dispatchEvent(event)


  # Handlers
  #
  handleRequestLoginDone: (json) ->
    if !json.errors
      location.href = json.previous_path
    else
      @setState(isSyncing: false)

      @setState
        errors: json.errors
        isResetShown: @isPasswordInvalid(json.errors)
  
  handleRequestLoginFail: (xhr) ->
    @setState(isSyncing: false)

    @setState
      errors:
        password: ['invalid']

  handleRequestResetDone: (json) ->
    component = cc.require('react/modals/reset-splash')

    event = new CustomEvent 'modal:push',
      detail:
        component: (component {})
    
    dispatchEvent(event)

  handleFormChange: (name, value) ->
    attributes = @state.attributes
    attributes[name] = value
    errors = @state.errors
    errors[name] = []

    @setState
      isResetShown: false
      attributes: attributes


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