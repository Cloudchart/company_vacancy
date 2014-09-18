##= require ./splash

#
#
tag = cc.require('react/dom')

SplashComponent = cc.require('react/modals/splash')

email_re = /.+@.+\..+/i


#
#
Component = React.createClass


  isEmailAndNameValid: ->
    email_re.test(@state.email) and @state.full_name.length > 0
  
  
  isValidForRegister: ->
    @isEmailAndNameValid() and @state.password.length > 0 and @props.invite.length > 0
  
  
  onEmailChange: (event) ->
    @setState({ email: event.target.value })


  onFullNameChange: (event) ->
    @setState({ full_name: event.target.value })


  onPasswordChange: (event) ->
    @setState({ password: event.target.value })

  onInputFocus: (event) ->
    errors = @state.errors[0..]
    errors.splice(errors.indexOf(event.target.name), 1)
    @setState
      errors: errors
  
  
  onRegisterDone: (json) ->
    @setState({ sync: false })

    if json.state == 'login'
      window.location.reload()
    
    if json.state == 'activation'
      event = new CustomEvent 'modal:push',
        detail:
          component: SplashComponent({
            header: 'Activation'
            note: 'We have sent an activation email.'
          })
      
      window.dispatchEvent(event)
  
  
  
  onRegisterFail: (xhr) ->
    @setState({ sync: false })

    errors = xhr.responseJSON.errors
    errors.splice(errors.indexOf('emails'), 1, 'email') if errors.indexOf('emails') > - 1
    @setState
      errors: errors
  
  onRegisterButtonClick: (event) ->
    @setState({ sync: true })

    $.ajax
      url:      '/register'
      type:     'POST'
      dataType: 'json'
      data:
        user:
          email:                  @state.email
          full_name:              @state.full_name
          password:               @state.password
          password_confirmation:  @state.password
          invite:                 @props.invite
    .done @onRegisterDone
    .fail @onRegisterFail


  onBackLinkClick: (event) ->
    event.preventDefault()
    
    event = new CustomEvent('modal:pop')

    window.dispatchEvent(event)
  
  
  onSubmit: (event) ->
    event.preventDefault()
    @onRegisterButtonClick()
  
  
  getDefaultProps: ->
    email:      ''
    full_name:  ''
  
  getInitialState: ->
    errors:     []
    email:      @props.email
    full_name:  @props.full_name
    password:   ''
    sync: false



  render: ->
    (tag.form {
      className:  'register'
      onSubmit:   @onSubmit
    },
      
      (tag.header {},
        (tag.a {
          href:     ''
          onClick:  @onBackLinkClick
        },
          (tag.i { className: 'fa fa-angle-left' })
        )
        'Sign Up'
      )
      
      
      (tag.fieldset {},
        
        # Name Input
        #
        (tag.label {},
          'Name'
          (tag.input {
            type:         'text'
            name:         'full_name'
            className:    'error' if @state.errors.indexOf('full_name') > -1
            autoFocus:    true
            autoComplete: 'off'
            value:        @state.full_name
            onFocus:      @onInputFocus
            onChange:     @onFullNameChange
          })
        )
      
        # Email Input
        #
        (tag.label {},
          'Email'
          (tag.input {
            type:         'text'
            name:         'email'
            className:    'error' if @state.errors.indexOf('email') > -1
            # autoFocus:    @state.email.length == 0
            autoComplete: @false
            value:        @state.email
            onFocus:      @onInputFocus
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
            className:    'error' if @state.errors.indexOf('password') > -1
            autoComplete: 'off'
            autoFocus:    @state.email.length > 0 and @state.full_name.length > 0
            value:        @state.password
            onFocus:      @onInputFocus
            onChange:     @onPasswordChange
          })
        )

        # Invite Code Input
        #
        (tag.label { style: { display: 'none' } },
          'Invite code'
          (tag.input {
            type:         'text'
            name:         'invite'
            disabled:     true
            autoComplete: 'off'
            value:        @props.invite
          })
        )
      )
      
      
      (tag.footer {},
        (tag.div { className: 'spacer' })

        (tag.button {
          type:       'submit'
          className:  'register'
          disabled:   !@isValidForRegister() or @state.sync
          onClick:    @onRegisterButtonClick
        },
          'Sign Up'
          (tag.i { className: 'fa fa-pencil-square-o' })
        )
      )
      
    )


#
#
cc.module('react/modals/register-form').exports = Component
