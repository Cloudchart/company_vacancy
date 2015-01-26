# @cjsx React.DOM

tag = React.DOM

InputComponent = cc.require('react/modals/input')

email_re = /.+@.+\..+/i

Field = require("components/form/field")

# Login mixin
#
LoginMixin =
  
  
  onLoginRequestDone: (json) ->
    if json.admin_path
      location.href = json.admin_path
    else
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


# Login button
#
LoginButton = (is_disabled, callback) ->
  (tag.button {
    type:       'submit'
    className:  'login cc'
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
    className:  'reset cc'
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
    className:  'invite cc'
    disabled:   is_disabled
    onClick:    callback
  },
    'invited?'
  )


#
#
LoginForm = React.createClass


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


  handleEmailChange: (event) ->
    delete @state.errors.email
    @setState(email: event.target.value)

  handlePasswordChange: (event) ->
    delete @state.errors.password
    @setState(password: event.target.value)

  
  getInitialState: ->
    email:    @props.email || ''
    password: ''
    errors:   {}
    reset:    false
    invite: @props.invite || ''
    full_name: @props.full_name || ''

  
  render: ->
    <form 
      ref       = 'form'
      className = 'login form-2'
      onSubmit  = {@onSubmit} >
    
      <header>Log In</header>

      <fieldset>

        <Field
          autoFocus    = { true }
          defaultValue = { @state.email }
          errors       = { @state.errors.email }
          name         = "email"
          onChange     = { @handleEmailChange }
          title        = "Email"
          type         = "email"
          value        = { @state.email } />

        <Field
          defaultValue = { @state.password }
          errors       = { @state.errors.password }
          name         = "password"
          onChange     = { @handlePasswordChange } 
          title        = "Password"
          type         = "password"
          value        = { @state.password } />
      </fieldset>
      
      <footer>

        {
          if @state.invite
            <div className='spacer'></div>
          else
            (InviteButton @isInviteButtonDisabled(), @onInviteButtonClick)
        }

        {
          (ResetButton @isResetButtonDisabled(), @onResetButtonClick) if @state.reset and @state.email
        }

        {
          (LoginButton @isLoginButtonDisabled(), @onLoginButtonClick)
        }
      </footer>
    </form>

module.exports = LoginForm
