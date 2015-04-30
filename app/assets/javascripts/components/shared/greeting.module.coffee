# @cjsx React.DOM

GlobalState    = require('global_state/state')
UserSyncApi    = require('sync/user_sync_api')

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


  # Helpers
  #
  isLoaded: ->
    @props.cursor.user.deref(false) && @props.cursor.tokens.deref(false)

  finishGreeting: ->
    @setState isSyncing: true

    UserSyncApi.deleteTempInfoBlock(@props.cursor.user, type: "greeting").then => 
      @clearTokens()

      GlobalState.fetch(new GlobalState.query.Query("Viewer{tokens}"), force: true)

  getGreeting: ->
    @props.cursor.tokens.filter (token) =>
      token.get('owner_id') == @props.cursor.user.get('uuid') &&
      token.get('name') == 'greeting'
    .first()

  clearTokens: ->
    TokenStore.cursor.items.forEach (item, id) =>
      if item.get('owner_id') == @props.cursor.user.get('uuid')
        TokenStore.cursor.items.removeIn(id)


  # Lifecycle methods
  #
  componentWillMount: ->
    @fetch() unless @isLoaded()


  # Renderers
  #
  renderText: ->
    <p>{ @getGreeting().get('data').get('content') }</p>


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
    
