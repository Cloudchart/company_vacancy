#
#
tag = cc.require('react/dom')

email_re = /.+@.+/i


#
#
Component = React.createClass


  isValidForLogin: ->
    @isValidForRegister() and @state.password.length > 0


  isValidForReset: ->
    @isValidForRegister()


  isValidForRegister: ->
    email_re.test(@state.email)
  

  onEmailChange: (event) ->
    @setState({ email: event.target.value })
  
  
  onPasswordChange: (event) ->
    @setState({ password: event.target.value })


  onLoginDone: (json) ->
    window.location.reload()
  
  
  onLoginFail: (xhr) ->
    @setState({ error: true })
  
  
  onSubmit: (event) ->
    event.preventDefault()
    
    $.ajax
      url:        '/login'
      type:       'POST'
      dataType:   'json'
      data:
        email:    @state.email
        password: @state.password
    .done @onLoginDone
    .fail @onLoginFail
  
  
  onFocus: (event) ->
    @setState({ error: false }) if event.target.name == 'password'
  
  
  onLoginButtonClick: (event) ->
    @onSubmit(event)


  onResetDone: (json) ->
    event = new CustomEvent 'modal:close'
    window.dispatchEvent(event)

  onResetFail: (xhr) ->


  onResetButtonClick: (event) ->
    $.ajax
      url:      '/profile/password/forgot'
      type:     'POST'
      dataType: 'json'
      data:
        email:  @state.email
    .done @onResetDone
    .fail @onResetFail


  onRegisterButtonClick: (event) ->
    RegisterFormComponent = cc.require('react/modals/register-form')

    event = new CustomEvent 'modal:push',
      detail:
        component: RegisterFormComponent
          email: @state.email

    window.dispatchEvent(event)
  
  
  getDefaultProps: ->
    email: ''
  
  
  getInitialState: ->
    email:    @props.email
    password: ''
    error:    false

  
  render: ->
    (tag.form {
      className:  'login'
      onSubmit:   @onSubmit
    },
      (tag.header {}, 'Login or Register')
      
      (tag.fieldset {},
        
        # Email Input
        #
        (tag.label {},
          'Email'
          (tag.input {
            type:         'text'
            autoFocus:    @state.email.length is 0
            autoComplete: 'off'
            value:        @state.email
            onChange:     @onEmailChange
          })
        )

        # Password Input
        #
        (tag.label {},
          'Password'
          (tag.input {
            type:         'password'
            name:         'password'
            className:    'error' if @state.error
            autoFocus:    @state.email.length isnt 0
            autoComplete: 'off'
            value:        @state.password
            onFocus:      @onFocus
            onChange:     @onPasswordChange
          })
        )
      )
      
      (tag.footer {},

        # Login Button
        #
        (tag.button {
          type:       'button'
          className:  'login'
          onClick:    @onLoginButtonClick
          disabled:   !@isValidForLogin()
        },
          'Login'
          (tag.i { className: 'fa fa-check' })
        )

        # Reset Button
        #
        (tag.button {
          type:       'button'
          className:  'reset'
          onClick:    @onResetButtonClick
          disabled:   !@isValidForReset()
        },
          'Reset'
          (tag.i { className: 'fa fa-repeat' })
        ) if @state.error

        # Register Button
        #
        (tag.button {
          type:       'button'
          className:  'alert register'
          onClick:    @onRegisterButtonClick
          disabled:   !@isValidForRegister()
        },
          'Register'
          (tag.i { className: 'fa fa-pencil-square-o' })
        )
      )
    )


#
#
cc.module('react/modals/login-form').exports = Component
