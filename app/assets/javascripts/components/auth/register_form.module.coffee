# @cjsx React.DOM

tag = cc.require('react/dom')

SplashComponent = cc.require('react/modals/splash')

Field   = require("components/form/field")
Buttons = require("components/form/buttons")

StandardButton = Buttons.StandardButton


RegisterForm = React.createClass

  # Component specifications
  #
  propTypes:
    attributes:   React.PropTypes.object
    errors:       React.PropTypes.object
    isDisabled:   React.PropTypes.bool
    onChange:     React.PropTypes.func
    onSubmit:     React.PropTypes.func

  getDefaultProps: ->
    attributes:   {}
    errors:       {}
    isDisabled:   false
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
          title        = "Name"
          value        = { @props.attributes.full_name } />
      
        <Field
          errors       = { @props.errors.email }
          name         = "email"
          onChange     = { @getChangeHandler("email") }
          title        = "Email"
          type         = "email"
          value        = { @props.attributes.email } />

        <Field
          errors       = { @props.errors.password }
          name         = "password"
          onChange     = { @getChangeHandler("password") } 
          title        = "Password"
          type         = "password"
          value        = { @props.attributes.password } />
      </fieldset>
      
      <footer>
        <div className="spacer"></div>
        <StandardButton
          className = "cc"
          disabled  = { @props.isDisabled }
          iconClass = "fa-pencil-square-o"
          onClick   = { @handleSubmit }
          text      = "Sign Up"
          type      = "submit" />
      </footer>
    </form>


module.exports = RegisterForm
