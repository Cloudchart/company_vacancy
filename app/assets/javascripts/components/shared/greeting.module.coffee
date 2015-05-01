# @cjsx React.DOM

GlobalState    = require('global_state/state')

TokenStore     = require('stores/token_store.cursor')
UserStore      = require('stores/user_store.cursor')

SyncButton     = require("components/form/buttons").SyncButton


# Exports
#
module.exports = React.createClass

  displayName: 'Greeting'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      tokens: ->
        """
          Viewer {
            tokens
          }
        """

  getDefaultProps: ->
    cursor:           
      tokens:  TokenStore.cursor.items 
      user:    UserStore.me()

  getInitialState: ->
    isSyncing:          false

  fetch: ->
    GlobalState.fetch(@getQuery('tokens'))

  onGlobalStateChange: ->
    @setState refreshed_at: + new Date


  # Helpers
  #
  isLoaded: ->
    @props.cursor.user.deref(false) && @props.cursor.tokens.deref(false)

  finishGreeting: ->
    @setState isSyncing: true
    TokenStore.destroyGreeting(@getGreeting().get('uuid'))

  getGreeting: ->
    TokenStore.findByUserAndName(@props.cursor.user, 'greeting')


  # Lifecycle methods
  #
  componentWillMount: ->
    @fetch() unless @isLoaded()


  # Renderers
  #
  renderText: ->
    <p dangerouslySetInnerHTML={__html: @getGreeting().get('data').get('content') } />


  render: ->
    return null unless @isLoaded() && @getGreeting()

    <section className="greeting">
      { @renderText() }
      <SyncButton
        className = "cc"
        onClick   = { @finishGreeting }
        sync      = { @state.isSyncing }
        text      = "Got This!" />
    </section>
    
