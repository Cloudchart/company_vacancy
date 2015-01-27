# @cjsx React.DOM

tag = cc.require('react/dom')

SplashComponent = cc.require('react/modals/splash')

Field   = require("components/form/field")
Buttons = require("components/form/buttons")

StandardButton = Buttons.StandardButton

email_re = /.+@.+\..+/i


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
    email:      @props.email || ''
    full_name:  @props.full_name || ''
    password:   ''
    sync: false



  render: ->
    <form
      className = 'register form-2'
      onSubmit  = { @onSubmit } >
      
      <header>Sign Up</header>
      
      <fieldset>
        <Field
          autoFocus    = { true }
          autoComplete = "off"
          errors       = { @state.errors.full_name }
          name         = "name"
          onChange     = { @onFullNameChange }
          onFocus      = { @onInputFocus }
          title        = "Name"
          value        = { @state.full_name } />
      
        <Field
          errors       = { @state.errors.email }
          name         = "email"
          onChange     = { @onEmailChange }
          onFocus      = { @onInputFocus }
          title        = "Email"
          type         = "email"
          value        = { @state.email } />

        <Field
          errors       = { @state.errors.password }
          name         = "password"
          onChange     = { @onPasswordChange } 
          onFocus      = { @onInputFocus }
          title        = "Password"
          type         = "password"
          value        = { @state.password } />
      </fieldset>
      
      <footer>
        <div className="spacer"></div>

        <StandardButton
          className = "cc"
          disabled  = { !@isValidForRegister() || @state.sync }
          iconClass = "fa-pencil-square-o"
          onClick   = { @onRegisterButtonClick }
          text      = "Sign Up"
          type      = "submit" />
      </footer>
    </form>


module.exports = Component
