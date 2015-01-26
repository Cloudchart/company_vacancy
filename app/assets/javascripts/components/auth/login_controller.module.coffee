# @cjsx React.DOM

LoginForm = require('components/auth/login_form')


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
    if json.admin_path
      location.href = json.admin_path
    else
      location.reload()
  
  handleLoginRequestFail: (xhr) ->
    @setState
      errors:
        password: 'invalid'
      isResetShown: true

  resetPasswordRequest: ->
    $.ajax
      url:      '/profile/password/forgot'
      type:     'POST'
      dataType: 'json'
      data:
        email:  @state.email
    .done @handleResetPasswordRequestDone

  handleResetPasswordRequestDone: ->
    component = cc.require('react/modals/reset-splash')

    event = new CustomEvent 'modal:push',
      detail:
        component: (component {})
    
    dispatchEvent(event)


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
      errors       = { @state.errors }
      isResetShown = { @state.isResetShown }
      onChange     = { @handleInputChange }
      onInvite     = { @handleInviteButtonClick }
      onSubmit     = { @handleSubmit } />

module.exports = LoginController