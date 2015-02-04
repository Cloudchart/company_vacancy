tag = React.DOM

SplashComponent = require('components/auth/invite_splash')

email_re = /.+@.+\..+/i

ModalStack  = require("components/modal_stack")

#
#
Component = React.createClass

  isEmailAndNameValid: ->
    email_re.test(@state.email) and @state.full_name.length > 0
  
  onEmailChange: (event) ->
    @setState({ email: event.target.value })


  onFullNameChange: (event) ->
    @setState({ full_name: event.target.value })
  
  onInputFocus: (event) ->
    errors = @state.errors[0..]
    errors.splice(errors.indexOf(event.target.name), 1)
    @setState
      errors: errors
  
  
  onInviteDone: (json) ->
    ModalStack.hide()
    ModalStack.show(SplashComponent({}))
  
  
  onInviteFail: (xhr) ->
    errors = xhr.responseJSON.errors
    errors.splice(errors.indexOf('emails'), 1, 'email') if errors.indexOf('emails') > - 1
    @setState
      errors: errors
  
  
  onInviteButtonClick: (event) ->
    event.preventDefault()

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


  onBackLinkClick: (event) ->
    event.preventDefault()
    
    ModalStack.hide()
  
  
  onSubmit: (event) ->
    event.preventDefault()
  
  getInitialState: ->
    errors:     []
    email:      @props.email || ''
    full_name:  @props.full_name || ''



  render: ->
    (tag.form {
      className:  'request-invite'
      onSubmit:   @onSubmit
    },
      
      (tag.header {},
        (tag.a {
          href:     ''
          onClick:  @onBackLinkClick
        },
          (tag.i { className: 'fa fa-angle-left' })
        )
        'Request Invite'
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
            autoComplete: @false
            value:        @state.email
            onFocus:      @onInputFocus
            onChange:     @onEmailChange
          })
        )

      )
      
      
      (tag.footer {},
        (tag.div { className: 'spacer' })

        (tag.button {
          type:       'submit'
          className:  'invite'
          disabled:   !@isEmailAndNameValid()
          onClick:    @onInviteButtonClick
        },
          'Request'
          (tag.i { className: 'fa fa-ticket' })
        )
      )
      
    )


#
#
module.exports = Component
