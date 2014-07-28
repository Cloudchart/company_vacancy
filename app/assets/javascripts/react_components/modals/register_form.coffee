#
#
tag = cc.require('react/dom')

email_re = /.+@.+/i

#
#
Component = React.createClass


  isEmailAndNameValid: ->
    email_re.test(@state.email) and @state.name.length > 0


  isValidForInvite: ->
    @isEmailAndNameValid() and !@isValidForRegister()
  
  
  isValidForRegister: ->
    @isEmailAndNameValid() and @state.password.length > 0 and @state.inviteCode.length > 0
  
  
  onLoginDone: (json) ->
    console.log json
  
  
  onLoginFail: (xhr) ->
  
  
  onSubmit: (event) ->
    event.preventDefault()
    
    $.ajax
      url:        '/login'
      type:       'POST'
      dataType:   'json'
      data:
        email:    @state.email
        password: @state.passwors
    .done @onLoginDone
    .fail @onLoginFail


  onEmailChange: (event) ->
    @setState({ email: event.target.value })


  onNameChange: (event) ->
    @setState({ name: event.target.value })


  onPasswordChange: (event) ->
    @setState({ password: event.target.value })


  onInviteCodeChange: (event) ->
    @setState({ inviteCode: event.target.value })


  onBackLinkClick: (event) ->
    event.preventDefault()
    
    event = new CustomEvent('modal:pop')

    window.dispatchEvent(event)
  
  
  getDefaultProps: ->
    email:      ''
    name:       ''
    inviteCode: ''
  
  
  getInitialState: ->
    email:      @props.email
    name:       @props.name
    inviteCode: @props.inviteCode
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
            autoFocus:    @state.email.length == 0
            autoComplete: @false
            value:        @state.email
            onChange:     @onEmailChange
          })
        )
        
        # Name Input
        #
        (tag.label {},
          'Name'
          (tag.input {
            type:         'text'
            autoFocus:    @state.email.length > 0
            autoComplete: 'off'
            value:        @state.name
            onChange:     @onNameChange
          })
        )

        # Password Input
        #
        (tag.label {},
          'Password'
          (tag.input {
            type:         'password'
            autoComplete: 'off'
            value:        @state.password
            onChange:     @onPasswordChange
          })
        )

        # Invite Code Input
        #
        (tag.label {},
          'Invite code'
          (tag.input {
            type:         'text'
            autoComplete: 'off'
            value:        @state.inviteCode
            onChange:     @onInviteCodeChange
          })
        )
      )
      
      
      (tag.footer {},
        (tag.button {
          type:       if @isValidForInvite() then 'submit' else 'button'
          className:  'invite'
          disabled:   !@isValidForInvite()
        },
          'Request Invite'
          (tag.i { className: 'fa fa-ticket' })
        )

        (tag.button {
          type:       if @isValidForRegister() then 'submit' else 'button'
          className:  'alert register'
          disabled:   !@isValidForRegister()
        },
          'Register'
          (tag.i { className: 'fa fa-pencil-square-o' })
        )
      )
      
    )

#
#
cc.module('react/modals/register-form').exports = Component
