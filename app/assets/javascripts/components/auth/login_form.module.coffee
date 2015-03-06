# @cjsx React.DOM

Field   = require("components/form/field")
Buttons = require("components/form/buttons")

StandardButton = Buttons.StandardButton
SyncButton     = Buttons.SyncButton


LoginForm = React.createClass

  # Component specifications
  #
  propTypes:
    errors:       React.PropTypes.object
    isDisabled:   React.PropTypes.bool
    isResetShown: React.PropTypes.bool
    isSyncing:    React.PropTypes.bool
    onChange:     React.PropTypes.func
    onInvite:     React.PropTypes.func
    onReset:      React.PropTypes.func
    onSubmit:     React.PropTypes.func

  getDefaultProps: ->
    errors:       {}
    isDisabled:   false
    isResetShown: false
    onChange:     ->
    onInvite:     ->
    onReset:      ->
    onSubmit:     ->


  # Helpers
  #
  getChangeHandler: (name) ->
    (event) => @props.onChange(name, event.target.value)


  # Handlers
  #
  handleSubmit: (event) ->
    event.preventDefault()
    @props.onSubmit(event)


  render: ->
    <form 
      ref       = "form"
      className = "login form-2"
      onSubmit  = { @handleSubmit } >
    
      <header>Log In</header>

      <fieldset>
        <Field
          autoFocus    = { true }
          errors       = { @props.errors.email }
          name         = "email"
          onChange     = { @getChangeHandler("email") }
          placeholder  = "Email"
          ref          = "email"
          title        = "Email"
          type         = "email" />

        <Field
          errors       = { @props.errors.password }
          name         = "password"
          onChange     = { @getChangeHandler("password") } 
          placeholder  = "Password"
          ref          = "password"
          title        = "Password"
          type         = "password" />
      </fieldset>
      
      <footer>

        {
          if false
            <div className="spacer"></div>
          else
            <StandardButton
              className = "transparent text"
              onClick   = { @props.onInvite }
              text      = "invited?" />
        }

        {
          if @props.isResetShown
            <StandardButton
              className = "cc"
              iconClass = "fa-repeat"
              onClick   = { @props.onReset }
              text      = "Reset" />
        }

        <SyncButton
          className = "cc"
          disabled  = { @props.isDisabled }
          iconClass = "fa-check"
          sync      = { @props.isSyncing }
          onClick   = { @props.handleSubmit }
          text      = "Login"
          type      = "submit" />
      </footer>
    </form>

module.exports = LoginForm
