tag = React.DOM

invite_re = /^([a-zA-Z]{1,4}\s){11}[a-zA-Z]{1,4}$/

RequestInviteForm = require("components/auth/request_invite_form")
ModalStack        = require("components/modal_stack")

#
#
Component = React.createClass
  
  isValidForRegister: ->
    invite_re.test(@state.invite)

  onInviteChange: (event) ->
    @setState({ invite: event.target.value })
  
  onInputFocus: (event) ->
    errors = @state.errors[0..]
    errors.splice(errors.indexOf(event.target.name), 1)
    @setState
      errors: errors
  
  onContinueDone: (json) ->
    if json.state == 'register'
      invite = @state.invite.split(' ').join('-').toLowerCase()

      location.href = "/signup?invite=#{invite}"     
  
  onContinueFail: (xhr) ->
    @setState({ errors: xhr.responseJSON.errors })
  
  onContinueButtonClick: (event) ->
    $.ajax
      url:      '/check_invite'
      type:     'GET'
      dataType: 'json'
      data:
        invite: @state.invite
    .done @onContinueDone
    .fail @onContinueFail

  onBackLinkClick: (event) ->
    event.preventDefault()
    
    ModalStack.hide()
 
  onInviteButtonClick: (event) ->
    event.preventDefault()

    ModalStack.hide()
    ModalStack.show(RequestInviteForm({}))

  onSubmit: (event) ->
    event.preventDefault()
  
  getInitialState: ->
    errors:     []
    invite:     @props.invite || ''

  render: ->
    (tag.form {
      className:  'invite'
      onSubmit:   @onSubmit
    },
      
      (tag.header {},
        (tag.a {
          href:     ''
          onClick:  @onBackLinkClick
        },
          (tag.i { className: 'fa fa-angle-left' })
        )
        'Invite'
      )
      
      
      (tag.fieldset {},
        # Invite Code Input
        #
        (tag.label {},
          'Invite code'
          (tag.input {
            type:         'text'
            name:         'invite'
            className:    'error' if @state.errors.indexOf('invite') > -1
            autoComplete: 'off'
            autoFocus:    true
            value:        @state.invite
            onFocus:      @onInputFocus
            onChange:     @onInviteChange
          })
        )
      )
          
      (tag.footer {},
        (tag.a {
          className: 'invite'
          href: ''
          onClick: @onInviteButtonClick
        },
          'Request Invite'
        )

        (tag.button {
          type:       'submit'
          className:  'continue'
          disabled:   !@isValidForRegister()
          onClick:    @onContinueButtonClick
        },
          'Continue'
          (tag.i { className: 'fa fa-chevron-circle-right' })
        )
      )
      
    )

#
#
module.exports = Component
