# @cjsx React.DOM

GlobalState    = require('global_state/state')
UserSyncApi    = require('sync/user_sync_api')

ModalStack     = require('components/modal_stack')

Buttons        = require("components/form/buttons")
SyncButton     = Buttons.SyncButton
StandardButton = Buttons.StandardButton

cx             = React.addons.classSet

# Exports
#
module.exports = React.createClass

  displayName: 'WelcomeTourSubscription'

  propTypes:
    onNext: React.PropTypes.func

  getInitialState: ->
    attributes: @getAttributesFromProps(@props)
    errors:     Immutable.List()
    isSyncing:  false


  # Helpers
  #
  getClassName: ->
    cx(
      "slide tour-subscription": true
      active: @props.active
    )

  getAttributesFromProps: (props) ->
    Immutable.Map({}).set('email', props.user.get('email') || '')

  finishTour: ->
    UserSyncApi.finishTour(@props.user, type: "welcome").then =>
      ModalStack.hide()

  subscribe: ->
    @setState isSyncing: true

    UserSyncApi.subscribe(@props.user, @state.attributes)
      .then =>
        GlobalState.fetch(new GlobalState.query.Query("Viewer{emails}"), { force: true })
        @finishTour()
      , (xhr) =>
        @setState
          errors: Immutable.List(xhr.responseJSON.errors)
          isSyncing: false


  # Handlers
  #
  handleChange: (name, event) ->
    @setState
      attributes: @state.attributes.set(name, event.target.value)
      errors:     @state.errors.remove(@state.errors.indexOf(name))


  # Renderers
  #
  renderForm: ->
    <form onSubmit={ @subcribe }>
      <input 
        className   = { if @state.errors.contains('email') then 'error' else null }
        onChange    = { @handleChange.bind(@, 'email') }
        placeholder = { @props.user.get('first_name') + ", your work email goes here" }
        type        = "email"
        value       = { @state.attributes.get('email') } />
      <SyncButton
        className = "cc"
        sync      = { @state.isSyncing }
        onClick   = { @subscribe }
        text      = "Sign me up!" />
    </form>


  render: ->
    <article className={ @getClassName() }>
      <StandardButton 
        className = "close transparent"
        iconClass = "cc-icon cc-times"
        onClick   = { @finishTour }/>
      <header>
        <div className="logo">
          <i className="svg-icon svg-cloudchart-logo"></i>
          Cloud<b>Chart</b>
        </div>
        <h1>Stay in the loop</h1>
        <h2>Add your email to profile: we'll keep you posted on new unicorns' timelines, useful insights, and new CloudChart features.</h2>
      </header>
      <div className="equation">
        <i className="svg-icon svg-cloudchart-logo" />
        +
        <i className="fa fa-envelope-o" />
        =
        <i className="fa fa-heart" />
      </div>
      { @renderForm() }
    </article>
