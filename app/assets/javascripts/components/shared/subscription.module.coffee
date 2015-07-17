# @cjsx React.DOM

GlobalState     = require('global_state/state')
UserSyncApi     = require('sync/user_sync_api')

TokenStore      = require('stores/token_store.cursor')
UserStore       = require('stores/user_store.cursor')

SyncButton      = require("components/form/buttons").SyncButton

cx              = React.addons.classSet

# Exports
#
module.exports = React.createClass

  displayName: "Subscription"

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:
    queries:
      viewer: ->
        """
          Viewer {
            edges {
              has_email,
              has_email_token,
              is_authenticated
            }
          }
        """

  fetch: ->
    GlobalState.fetch(@getQuery('viewer')).done =>
      @setState
        ready: true


  # Events
  #

  handleSubmit: (event) ->
    event.preventDefault()

    @setState
      sync: true

    UserSyncApi.subscribe(@cursor.me, Immutable.Seq({ email: @state.email })).then(@subscribeDone, @subscribeFail)


  subscribeDone: ->
    GlobalState.fetch(@getQuery('viewer'), { force: true }).done =>
      @setState
        sync:               false
        shouldRenderThank:  true

    null


  subscribeFail: ->
    @setState
      sync:   false
      error:  true

    snabbt(@refs['form'].getDOMNode(), 'attention', {
      position: [50, 0, 0],
      springConstant: 2.4,
      springDeceleration: 0.9
    })

    null


  handleChange: (event) ->
    @setState
      email:  event.target.value
      error:  false


  # Lifecycle
  #
  getInitialState: ->
    email:  ''
    error:              false
    ready:              false
    sync:               false
    shouldRenderThank:  false


  componentWillMount: ->
    @cursor =
      me: UserStore.me()

    @fetch()


  # Renders
  #
  renderThank: (message = null) ->
    message ||= 'Thanks! We’ll keep you posted.'

    <section className="subscription one-line">
      <header>
        { message }
      </header>
    </section>

  renderHeader: ->
    return null unless @props.text

    <header>
      { @props.text }
    </header>


  # Main Render
  #
  render: ->
    return @renderThank() if @state.shouldRenderThank

    return null unless @state.ready
    return null unless @cursor.me.get('is_authenticated', false)

    if @cursor.me.get('has_email', false) or @cursor.me.get('has_email_token', false)
      if @props.displaySubscribedMessage
        return @renderThank('You’re already subscribed!')
      else
        return null

    inputClassName = cx
      'cc-input':   true
      'error':      @state.error

    subscriptionClasses = cx
      'subscription': true
      'one-line': @props.text

    <section className = { subscriptionClasses }>
      { @renderHeader() }

      <form ref="form" onSubmit={ @handleSubmit }>
        <input
          autoFocus   = { true }
          className   = { inputClassName }
          value       = { @state.email }
          onChange    = { @handleChange }
          placeholder = "Please enter your email"
          disabled    = { @state.sync }
        />

        <SyncButton
          className   = "cc"
          text        = "Subscribe"
          sync        = { @state.sync }
          type        = "submit"
        />
      </form>
    </section>
