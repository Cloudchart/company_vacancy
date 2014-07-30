##= require ./input
##= require ./reset_splash
#
#
tag = cc.require('react/dom')

InputComponent = cc.require('react/modals/input')

email_re = /.+@.+/i


# Login mixin
#
LoginMixin =
  
  
  onLoginRequestDone: ->
    location.reload()
  
  
  onLoginRequestFail: ->
    @setState
      errors:
        password: 'invalid'
      reset: true
  
  
  loginRequest: ->
    $.ajax
      url:        '/login'
      type:       'POST'
      dataType:   'json'
      data:
        email:      @state.email
        password:   @state.password
    .done @onLoginRequestDone
    .fail @onLoginRequestFail


# Reset password mixin
#
ResetPasswordMixin =
  

  onResetPasswordRequestDone: ->
    component = cc.require('react/modals/reset-splash')

    event = new CustomEvent 'modal:push',
      detail:
        component: (component {})
    
    dispatchEvent(event)
  

  resetPasswordRequest: ->
    $.ajax
      url:      '/profile/password/forgot'
      type:     'POST'
      dataType: 'json'
      data:
        email:  @state.email
    .done @onResetPasswordRequestDone


# Email
#
EmailInput = (value, is_error, callback) ->
  (tag.label {},
    'Email'
    (InputComponent {
      type:       'email'
      name:       'email'
      className:  'error' if is_error
      autoFocus:  true
      value:      value
      onChange:   callback
    })
  )


# Password
#
PasswordInput = (value, is_error, callback) ->
  (tag.label {},
    'Password'
    (InputComponent {
      type:       'password'
      name:       'password'
      className:  'error' if is_error
      value:      value
      onChange:   callback
    })
  )


# Login button
#
LoginButton = (is_disabled, callback) ->
  (tag.button {
    type:       'submit'
    className:  'login'
    disabled:   is_disabled
    onClick:    callback
  },
    'Login'
    (tag.i { className: 'fa fa-check' })
  )


# Reset Button
#
ResetButton = (is_disabled, callback) ->
  (tag.button {
    type:       'button'
    className:  'reset'
    disabled:   is_disabled
    onClick:    callback
  },
    'Reset'
    (tag.i { className: 'fa fa-repeat' })
  )


# Register button
#
RegisterButton = (is_disabled, callback) ->
  (tag.button {
    type:       'submit'
    className:  'alert register'
    disabled:   is_disabled
    onClick:    callback
  },
    'Register'
    (tag.i { className: 'fa fa-pencil-square-o' })
  )


#
#
Component = React.createClass


  mixins: [
    LoginMixin
    ResetPasswordMixin
  ]


  isLoginButtonDisabled: ->
    !email_re.test(@state.email) or @state.password.length == 0
  
  
  isResetButtonDisabled: ->
    !email_re.test(@state.email)

  
  isRegisterButtonDisabled: ->
    !email_re.test(@state.email)

  
  onLoginButtonClick: (event) ->
    event.preventDefault()
    
    @loginRequest()
  
  
  onResetButtonClick: (event) ->
    event.preventDefault()
    
    @resetPasswordRequest()
  
  
  onRegisterButtonClick: (event) ->
    event.preventDefault()
    
    alert 'register'


  onSubmit: (event) ->
    event.preventDefault()


  onChange: (event) ->
    delete @state.errors[event.target.name]

    data = {} ; data[event.target.name] = event.target.value

    @setState(data)
  
  
  getInitialState: ->
    email:    @props.email || ''
    password: ''
    errors:   {}
    reset:    false

  
  render: ->
    (tag.form {
      className:  'login'
      onSubmit:   @onSubmit
    },
    
      # Header
      #
      (tag.header {}, 'Login or Register')

      # Fieldset
      # Email & Password fields
      #
      (tag.fieldset {},

        # Email Input
        #
        (EmailInput @state.email, !!@state.errors['email'], @onChange)

        # Password Input
        #
        (PasswordInput @state.password, !!@state.errors['password'], @onChange)
      )
      
      # Footer
      # Login & Reset & Register buttons
      #
      (tag.footer {},

        # Login Button
        #
        (LoginButton @isLoginButtonDisabled(), @onLoginButtonClick)

        # Reset Button
        #
        (ResetButton @isResetButtonDisabled(), @onResetButtonClick) if @state.reset

        # Register Button
        #
        (RegisterButton @isRegisterButtonDisabled(), @onRegisterButtonClick)
      )
    )


#
#
cc.module('react/modals/login-form').exports = Component
