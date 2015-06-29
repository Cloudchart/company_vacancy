# @cjsx React.DOM

GlobalState    = require('global_state/state')
UserSyncApi    = require('sync/user_sync_api')

TokenStore     = require('stores/token_store.cursor')
UserStore      = require('stores/user_store.cursor')

SyncButton     = require("components/form/buttons").SyncButton


# Exports
#
module.exports = React.createClass

  displayName: 'Subscription'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      tokens: ->
        """
          Viewer {
            tokens
          }
        """

  propTypes:
    asBlock:               React.PropTypes.bool
    buttonText:            React.PropTypes.string
    onSubscriptionDone:    React.PropTypes.func
    text:                  React.PropTypes.string

  getDefaultProps: ->
    buttonText:         "Sign me up"
    text:               null
    asBlock:            false
    onSubscriptionDone: ->
    cursor:
      tokens:  TokenStore.cursor.items
      user:    UserStore.me()

  getInitialState: ->
    attributes:         @getAttributesFromCursor()
    errors:             Immutable.List()
    isLoaded:           false
    isSyncing:          false

  onGlobalStateChange: ->
    @setState attributes: @getAttributesFromCursor()

  fetch: ->
    GlobalState.fetch(@getQuery('tokens'))


  # Helpers
  #
  isLoaded: ->
    @props.cursor.user.deref(false) && @state.isLoaded

  getEmailFromTokens: ->
    token = @props.cursor.tokens.filter (token) =>
      token.get('owner_id') == @props.cursor.user.get('uuid') &&
      token.get('name') == 'email_verification'
    .first()

    return null unless token
    token.get('data').get('address')

  getUserEmail: ->
    @props.cursor.user.get('email') || @getEmailFromTokens() || ''

  getAttributesFromCursor: ->
    Immutable.Map({}).set('email', @getUserEmail())

  subscribe: (event) ->
    event.preventDefault()

    @setState isSyncing: true

    UserSyncApi.subscribe(@props.cursor.user, @state.attributes)
      .then =>
        GlobalState.fetch(new GlobalState.query.Query("Viewer{tokens,emails}"), { force: true })
        @props.onSubscriptionDone()
      , (xhr) =>
        @setState
          errors: Immutable.List(xhr.responseJSON.errors)
          isSyncing: false

  isSubscribed: ->
    !!@props.cursor.tokens.filter (token) =>
      token.get('owner_id') == @props.cursor.user.get('uuid') &&
      token.get('name') == 'subscription'
    .size

  getClassName: ->
    if @props.asBlock then "subscription standalone" else "subscription"


  # Handlers
  #
  handleChange: (name, event) ->
    @setState
      attributes: @state.attributes.set(name, event.target.value)
      errors:     @state.errors.remove(@state.errors.indexOf(name))


  # Lifecycle methods
  #
  componentWillMount: ->
    @fetch().then => @setState(isLoaded: true) unless @isLoaded()


  # Renderers
  #
  renderPlaceholder: ->
    return null unless @props.children

    <section className="subscription">
      { @props.children }
    </section>

  renderText: ->
    return null unless @props.text

    <p>{ @props.text }</p>

  renderEmail: ->
    return null if @props.cursor.user.get('email')

    <input
      className   = { if @state.errors.contains('email') then 'cc-input error' else 'cc-input' }
      onChange    = { @handleChange.bind(@, 'email') }
      placeholder = { "Please enter your email" }
      type        = "email"
      value       = { @state.attributes.get('email') } />


  render: ->
    return null unless @isLoaded()
    return null unless @props.cursor.user.get('twitter')

    if @isSubscribed()
      @renderPlaceholder()
    else
      <section className={ @getClassName() }>
        { @renderText() }
        <form onSubmit={ @subscribe }>
          { @renderEmail() }
          <SyncButton
            className = "cc"
            sync      = { @state.isSyncing }
            text      = { @props.buttonText }
            type      = "submit" />
        </form>
      </section>
