# Imports
#
tag = cc.require('react/dom')


InputMixin =
  
  Input: (props) ->
    


# Main Component
#
Component = React.createClass


  mixins: [
    InputMixin
  ]
  
  
  isResetButtonEnabled: ->
    @state.password.length > 0 and @state.password == @state.password_confirmation
  
  
  onResetDone: (json) ->
    @setState
      synchronizing: false

    window.dispatchEvent(new CustomEvent('modal:close'))
    window.location.reload()
  
  
  onResetFail: (xhr) ->
    @setState
      synchronizing: false
  
  
  onSubmit: (event) ->
    event.preventDefault()
    
    @setState
      synchronizing: true
    
    $.ajax
      url:        "/profile/password/#{@props.token}/reset"
      type:       "POST"
      dataType:   "json"
      data:
        user:
          password:               @state.password
          password_confirmation:  @state.password_confirmation
    .done @onResetDone
    .fail @onResetFail
  
  
  onInputChange: (event) ->
    data = {}
    data[event.target.name] = event.target.value
    @setState(data)
  
  
  getInitialState: ->
    password:               ''
    password_confirmation:  ''


  render: ->
    (tag.form {
      disabled:   @state.synchronizing
      className:  'password-reset'
      onSubmit:   @onSubmit
    },
      (tag.header {},
        'Reset Password'
      )
      
      
      (tag.fieldset {},
      
        (tag.label {},
          'Password',
          (tag.input {
            type:       'password'
            name:       'password'
            value:      @state.password
            autoFocus:  true
            onChange:   @onInputChange
          })
        )
      
        (tag.label {},
          'Again',
          (tag.input {
            type:     'password'
            name:     'password_confirmation'
            value:    @state.password_confirmation
            onChange: @onInputChange
          })
        )
      
      )
    
    
      (tag.footer {},
        (tag.div { className: 'spacer' })
      
        (tag.button {
          type:     'submit'
          disabled: !@isResetButtonEnabled()
          onClick:  @ResetButtonClick
        },
          "Reset password"
          (tag.i { className: 'fa fa-check' })
        )

        (tag.div { className: 'spacer' })
      )
    )


# Exports
#
cc.module('react/modals/password-reset-form').exports = Component
