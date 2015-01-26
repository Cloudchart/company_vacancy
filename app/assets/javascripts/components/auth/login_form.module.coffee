# @cjsx React.DOM

tag = React.DOM

InputComponent = cc.require('react/modals/input')

Field   = require("components/form/field")
Buttons = require("components/form/buttons")

StandardButton = Buttons.StandardButton


LoginForm = React.createClass

  # Component specifications
  #
  propTypes:
    attributes:   React.PropTypes.object
    errors:       React.PropTypes.object
    isResetShown: React.PropTypes.bool
    onChange:     React.PropTypes.func
    onInvite:     React.PropTypes.func
    onSubmit:     React.PropTypes.func

  getDefaultProps: ->
    attributes:   {}
    errors:       {}
    isResetShown: false
    onChange:     ->
    onInvite:     ->
    onSubmit:     ->

  getChangeHandler: (name) ->
    (event) => @props.onChange(name, event.target.value)

  handleSubmit: (event) ->
    event.preventDefault()

  render: ->
    <form 
      ref       = "form"
      className = "login form-2"
      onSubmit  = { @handleSubmit } >
    
      <header>Log In</header>

      <fieldset>
        <Field
          autoFocus    = { true }
          defaultValue = { @props.attributes.email }
          errors       = { @props.errors.email }
          name         = "email"
          onChange     = { @getChangeHandler("email") }
          title        = "Email"
          type         = "email"
          value        = { @props.attributes.email } />

        <Field
          defaultValue = { @props.attributes.password }
          errors       = { @props.errors.password }
          name         = "password"
          onChange     = { @getChangeHandler("password") } 
          title        = "Password"
          type         = "password"
          value        = { @props.attributes.password } />
      </fieldset>
      
      <footer>

        {
          if false
            <div className="spacer"></div>
          else
            <StandardButton
              className = "transparent"
              onClick   = { @props.onInvite }
              text      = "invited?" />
        }

        {
          if @props.isResetShown && @props.attributes.email
            <StandardButton
              className = "cc"
              iconClass = "fa-repeat"
              onClick   = { @handleResetButtonClick }
              text      = "Reset" />
        }

        <StandardButton
          className = "cc"
          iconClass = "fa-check"
          onClick   = { @props.onSubmit }
          text      = "Login"
          type      = "submit" />
      </footer>
    </form>

module.exports = LoginForm
