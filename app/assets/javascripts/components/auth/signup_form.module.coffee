# @cjsx React.DOM

tag = cc.require('react/dom')

SplashComponent = require('react_components/modals/splash')

Field   = require("components/form/field")
Buttons = require("components/form/buttons")

StandardButton = Buttons.StandardButton
SyncButton     = Buttons.SyncButton


RegisterForm = React.createClass

  # Component specifications
  #
  propTypes:
    attributes:   React.PropTypes.object
    errors:       React.PropTypes.object
    isDisabled:   React.PropTypes.bool
    isSyncing:    React.PropTypes.bool
    onChange:     React.PropTypes.func
    onSubmit:     React.PropTypes.func

  getDefaultProps: ->
    attributes:   {}
    errors:       {}
    isDisabled:   false
    isSyncing:    false
    onChange:     ->
    onSubmit:     ->


  # Helpers
  #
  getChangeHandler: (name) ->
    (event) => @props.onChange(name, event.target.value)

  handleSubmit: (event) ->
    event.preventDefault()
    @props.onSubmit()


  render: ->
    <form
      className = "register form-2"
      onSubmit  = { @handleSubmit } >
      
      <header>Sign Up</header>
      
      <fieldset>
        <Field
          autoFocus    = { true }
          errors       = { @props.errors.full_name }
          name         = "name"
          onChange     = { @getChangeHandler("full_name") }
          placeholder  = "Name"
          title        = "Name"
          value        = { @props.attributes.full_name } />
      
        <Field
          errors       = { @props.errors.email }
          name         = "email"
          onChange     = { @getChangeHandler("email") }
          placeholder  = "Email"
          title        = "Email"
          type         = "email"
          value        = { @props.attributes.email } />

        <Field
          errors       = { @props.errors.password }
          onChange     = { @getChangeHandler("password") } 
          placeholder  = "Password"
          title        = "Password"
          type         = "password"
          value        = { @props.attributes.password } />
      </fieldset>
      
      <footer>
        <div className="spacer"></div>

        <SyncButton
          className = "cc"
          disabled  = { @props.isDisabled }
          sync      = { @props.isSyncing }
          iconClass = "fa-pencil-square-o"
          onClick   = { @handleSubmit }
          text      = "Sign Up"
          type      = "submit" />
      </footer>
    </form>


module.exports = RegisterForm
