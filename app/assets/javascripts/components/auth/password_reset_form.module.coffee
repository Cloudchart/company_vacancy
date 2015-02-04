# @cjsx React.DOM

ModalStack = require('components/modal_stack')
    
Field   = require("components/form/field")
Buttons = require("components/form/buttons")

SyncButton     = Buttons.SyncButton

# Main Component
#
Component = React.createClass
  
  
  isResetButtonEnabled: ->
    @state.password.length > 0 and @state.password == @state.password_confirmation
  
  
  onResetDone: (json) ->
    @setState
      synchronizing: false

    window.location.href = json.previous_path
  
  
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
    <form 
      disabled  = { @state.synchronizing }
      ref       = "form"
      className = "password-reset form-2"
      onSubmit  = { @onSubmit } >
    
      <header>Reset Password</header>

      <fieldset>
        <Field
          autoFocus    = { true }
          onChange     = { @onInputChange }
          placeholder  = "Password"
          title        = "Password"
          type         = "password"
          name         = "password"
          value        = { @state.password } />

        <Field
          onChange     = { @onInputChange } 
          placeholder  = "Again"
          title        = "Again"
          type         = "password"
          name         = "password_confirmation"
          value        = { @props.password_confirmation } />
      </fieldset>
      
      <footer>

        <div className="spacer"></div>

        <SyncButton
          className = "cc"
          disabled  = { !@isResetButtonEnabled() }
          iconClass = "fa-check"
          sync      = { @props.synchronizing }
          onClick   = { @props.ResetButtonClick }
          text      = "Reset password"
          type      = "submit" />
      </footer>
    </form>


# Exports
#
module.exports = Component
