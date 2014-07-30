##= require ./splash

#
#
tag = cc.require('react/dom')

SplashComponent = cc.require('react/modals/invite-splash')

email_re = /@/i


#
#
Component = React.createClass


  isEmailAndNameValid: ->
    email_re.test(@state.email) and @state.full_name.length > 0


  isValidForInvite: ->
    @isEmailAndNameValid() and !@isValidForRegister()
  
  
  isValidForRegister: ->
    @isEmailAndNameValid() and @state.password.length > 0 and @state.invite.length > 0
  
  
  onEmailChange: (event) ->
    @setState({ email: event.target.value })


  onFullNameChange: (event) ->
    @setState({ full_name: event.target.value })


  onPasswordChange: (event) ->
    @setState({ password: event.target.value })


  onInviteChange: (event) ->
    @setState({ invite: event.target.value })
  
  
  onInputFocus: (event) ->
    errors = @state.errors[0..]
    errors.splice(errors.indexOf(event.target.name), 1)
    @setState
      errors: errors
  
  
  onInviteDone: (json) ->
    event = new CustomEvent 'modal:push',
      detail:
        component: SplashComponent({})
    
    window.dispatchEvent(event)
  
  
  onInviteFail: (xhr) ->
    console.log xhr.responseJSON
  
  
  onInviteButtonClick: (event) ->
    $.ajax
      url:      '/invite'
      type:     'POST'
      dataType: 'json'
      data:
        user:
          email:      @state.email
          full_name:  @state.full_name
    .done @onInviteDone
    .fail @onInviteFail
  
  
  onRegisterDone: (json) ->
    if json.state == 'login'
      window.location.reload()
    
    if json.state == 'activate'
      pass
  
  
  
  onRegisterFail: (xhr) ->
    errors = xhr.responseJSON.errors
    errors.splice(errors.indexOf('emails'), 1, 'email') if errors.indexOf('emails') > - 1
    @setState
      errors: errors
  
  
  onRegisterButtonClick: (event) ->
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
          invite:                 @state.invite
    .done @onRegisterDone
    .fail @onRegisterFail


  onBackLinkClick: (event) ->
    event.preventDefault()
    
    event = new CustomEvent('modal:pop')

    window.dispatchEvent(event)
  
  
  getDefaultProps: ->
    email:      ''
    full_name:  ''
    invite:     ''
  
  
  getInitialState: ->
    errors:     []
    email:      @props.email
    full_name:  @props.full_name
    invite:     @props.invite
    password:   ''



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
        'Register'
      )
      
      
      (tag.fieldset {},
      
        # Email Input
        #
        (tag.label {},
          'Email'
          (tag.input {
            type:         'text'
            name:         'email'
            className:    'error' if @state.errors.indexOf('email') > -1
            autoFocus:    @state.email.length == 0
            autoComplete: @false
            value:        @state.email
            onFocus:      @onInputFocus
            onChange:     @onEmailChange
          })
        )
        
        # Name Input
        #
        (tag.label {},
          'Name'
          (tag.input {
            type:         'text'
            name:         'full_name'
            className:    'error' if @state.errors.indexOf('full_name') > -1
            autoFocus:    @state.email.length > 0
            autoComplete: 'off'
            value:        @state.full_name
            onFocus:      @onInputFocus
            onChange:     @onFullNameChange
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
            value:        @state.password
            onFocus:      @onInputFocus
            onChange:     @onPasswordChange
          })
        )

        # Invite Code Input
        #
        (tag.label {},
          'Invite code'
          (tag.input {
            type:         'text'
            name:         'invite'
            className:    'error' if @state.errors.indexOf('invite') > -1
            autoComplete: 'off'
            value:        @state.invite
            onFocus:      @onInputFocus
            onChange:     @onInviteChange
          })
        )
      )
      
      
      (tag.footer {},
        (tag.button {
          type:       'button'
          className:  'invite'
          disabled:   !@isValidForInvite()
          onClick:    @onInviteButtonClick
        },
          'Request Invite'
          (tag.i { className: 'fa fa-ticket' })
        )

        (tag.button {
          type:       'button'
          className:  'alert register'
          disabled:   !@isValidForRegister()
          onClick:    @onRegisterButtonClick
        },
          'Register'
          (tag.i { className: 'fa fa-pencil-square-o' })
        )
      )
      
    )


#
#
cc.module('react/modals/register-form').exports = Component
