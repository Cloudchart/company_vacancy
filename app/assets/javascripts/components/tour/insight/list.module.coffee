# @cjsx React.DOM

GlobalState    = require('global_state/state')
UserSyncApi    = require('sync/user_sync_api')

TokenStore     = require('stores/token_store.cursor')

ModalStack     = require('components/modal_stack')

Buttons        = require("components/form/buttons")
SyncButton     = Buttons.SyncButton
StandardButton = Buttons.StandardButton

# Exports
#
module.exports = React.createClass

  displayName: 'InsightTourLesson'

  propTypes:
    className: React.PropTypes.string

  getInitialState: ->
    isSyncing:  false


  finishTour: ->
    @setState isSyncing: true

    UserSyncApi.finishTour(@props.user, type: "insight").then =>
      @clearTokens()

      GlobalState.fetch(new GlobalState.query.Query("Viewer{tokens}"), force: true)
      ModalStack.hide()

  clearTokens: ->
    TokenStore.cursor.items.forEach (item, id) =>
      if item.get('owner_id') == @props.user.get('uuid')
        TokenStore.cursor.items.removeIn(id)


  render: ->
    <article className={ "tour-insight-list " + @props.className }>
      <p>
        The link to your Insights board is at the top of the page; your insight can also be found next to the post you've commented on.
      </p>
      <div className="insight-list-placeholder"></div>
      <SyncButton
        className = "cc"
        sync      = { @state.isSyncing }
        onClick   = { @finishTour }
        text      = "Got This!" />
    </article>