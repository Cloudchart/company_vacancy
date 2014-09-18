##= require ./input
##= require ./reset_splash
#
#
tag = cc.require('react/dom')

InputComponent = cc.require('react/modals/input')

email_re = /.+@.+\..+/i

# Login mixin
#
LoginMixin =
  
  
  onLoginRequestDone: ->
    location.reload()
  
  
  onLoginRequestFail: (xhr) ->
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
        email:      @refs.email.getDOMNode().value
        password:   @refs.password.getDOMNode().value
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
        email:  @refs.email.getDOMNode().value
    .done @onResetPasswordRequestDone


# Register mixin
#
RegisterMixin =
  
  onInviteButtonClick: (event) ->
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


# Email
#
EmailInput = (value, is_error, callback) ->
  (tag.label {},
    'Email'
    (InputComponent {
      ref:        'email'
      type:       'email'
      name:       'email'
      className:  'error' if is_error
      autoFocus:  true
      defaultValue:      value
      #onChange:   callback
    })
  )


# Password
#
PasswordInput = (value, is_error, callback) ->
  (tag.label {},
    'Password'
    (InputComponent {
      ref:        'password'
      type:       'password'
      name:       'password'
      className:  'error' if is_error
      defaultValue:      value
      #onChange:   callback
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
InviteButton = (is_disabled, callback) ->
  (tag.a {
    href: ''
    className:  'invite'
    disabled:   is_disabled
    onClick:    callback
  },
    'invited?'
  )


#
#
Component = React.createClass


  mixins: [
    LoginMixin
    ResetPasswordMixin
    RegisterMixin
  ]


  isLoginButtonDisabled: ->
    #!email_re.test(@state.email) or @state.password.length == 0
    false
  
  
  isResetButtonDisabled: ->
    #!email_re.test(@state.email)
    false

  
  isInviteButtonDisabled: ->
    #!email_re.test(@state.email)
    false

  
  onLoginButtonClick: (event) ->
    event.preventDefault()
    
    @loginRequest()
  
  
  onResetButtonClick: (event) ->
    event.preventDefault()
    
    @resetPasswordRequest()
  
  
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
    invite: @props.invite || ''
    full_name: @props.full_name || ''

  
  render: ->
    (tag.form {
      ref:        'form'
      className:  'login'
      onSubmit:   @onSubmit
    },
    
      # Header
      #
      (tag.header {}, 'Log In')

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

        # Register Button
        #
        if @state.invite
          (tag.div { className: 'spacer' })
        else
          (InviteButton @isInviteButtonDisabled(), @onInviteButtonClick)

        # Reset Button
        #
        (ResetButton @isResetButtonDisabled(), @onResetButtonClick) if @state.reset and @refs.email.getDOMNode().value

        # Login Button
        #
        (LoginButton @isLoginButtonDisabled(), @onLoginButtonClick)
      )
    )


#
#
cc.module('react/modals/login-form').exports = Component
