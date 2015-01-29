# @cjsx React.DOM

Field       = require("components/form/field")
Buttons     = require("components/form/buttons")

SyncButton  = Buttons.SyncButton

SetupForm = React.createClass

  # Component specifications
  #
  propTypes:
    attributes:   React.PropTypes.instanceOf(Immutable.Map)
    errors:       React.PropTypes.instanceOf(Immutable.Map)
    isDisabled:   React.PropTypes.bool
    isSyncing:    React.PropTypes.bool
    onChange:     React.PropTypes.func
    onSubmit:     React.PropTypes.func

  getDefaultProps: ->
    attributes:   Immutable.Map()
    errors:       Immutable.Map()
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
      className = "setup form-2"
      onSubmit  = { @handleSubmit } >
      
      <header>Setup</header>
      
      <fieldset>
        <Field
          errors       = { @props.errors.password }
          name         = "password"
          onChange     = { @getChangeHandler("password") } 
          placeholder  = "Password"
          title        = "Password"
          type         = "password"
          value        = { @props.attributes.get("password") } />
      </fieldset>
      
      <footer>
        <div className="spacer"></div>

        <SyncButton
          className = "cc"
          disabled  = { @props.isDisabled }
          sync      = { @props.isSyncing }
          iconClass = "fa-pencil-square-o"
          onClick   = { @handleSubmit }
          text      = "Setup"
          type      = "submit" />
      </footer>
    </form>


module.exports = SetupForm