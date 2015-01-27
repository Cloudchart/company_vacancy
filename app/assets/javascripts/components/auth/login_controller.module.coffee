# @cjsx React.DOM

LoginForm = require('components/auth/login_form')


Errors =
  email:
    missing:  "Enter email, please"
    invalid:  "There are no users with such an email"
  password:
    invalid:  "The password is wrong"

getErrorMessages = (errorsLists) ->
  errors = _.mapValues errorsLists, (errors, attributeName) ->
    _.map errors, (errorName) ->
      Errors[attributeName][errorName]

  errors



LoginController = React.createClass

  # Component Specifications
  # 
  getInitialState: ->
    attributes: {}
    errors:     {}


  # Helpers
  #
  loginRequest: ->
    $.ajax
      url:        '/login'
      type:       'POST'
      dataType:   'json'
      data:
        email:      @state.attributes.email
        password:   @state.attributes.password
    .done @handleLoginRequestDone
    .fail @handleLoginRequestFail

  handleLoginRequestDone: (json) ->
    if !json.errors
      location.href = json.previous_path
    else
      @setState
        errors: json.errors
        isResetShown: json.errors.password
  
  handleLoginRequestFail: (xhr) ->
    @setState
      errors:
        password: ['invalid']


  resetPasswordRequest: ->
    $.ajax
      url:      '/profile/password/forgot'
      type:     'POST'
      dataType: 'json'
      data:
        email:  @state.attributes.email
    .done @handleResetPasswordRequestDone

  handleResetPasswordRequestDone: (json) ->
    if !json.errors
      component = cc.require('react/modals/reset-splash')

      event = new CustomEvent 'modal:push',
        detail:
          component: (component {})
      
      dispatchEvent(event)
    else
      @setState
        resetErrors: json.errors


  # Handlers
  # 
  handleInviteButtonClick: (event) ->
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

  handleInputChange: (name, value) ->
    attributes = @state.attributes
    attributes[name] = value

    @setState(attributes: attributes)

  handleSubmit: ->
    @loginRequest()


  render: ->
    <LoginForm
      attributes   = { @state.attributes }
      errors       = { getErrorMessages(@state.errors) }
      isResetShown = { @state.isResetShown }
      onChange     = { @handleInputChange }
      onInvite     = { @handleInviteButtonClick }
      onReset      = { @resetPasswordRequest }
      onSubmit     = { @handleSubmit } />

module.exports = LoginController