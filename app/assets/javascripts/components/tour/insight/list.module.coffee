# @cjsx React.DOM

GlobalState    = require('global_state/state')

TokenStore     = require('stores/token_store.cursor')
UserStore      = require('stores/user_store.cursor')

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

  getInsightTour: ->
    TokenStore.findByUserAndName(UserStore.me(), 'insight_tour')

  finishTour: ->
    @setState isSyncing: true
    TokenStore.destroyInsightTour(@getInsightTour().get('uuid')).then -> ModalStack.hide()


  render: ->
    <article className={ "tour-insight-list " + @props.className }>
      <p>
        { "The link to your Insights board is at the top of the page; your insight can also be found next to the post you've commented on." }
      </p>
      <div className="insight-list-placeholder"></div>
      <SyncButton
        className = "cc"
        sync      = { @state.isSyncing }
        onClick   = { @finishTour }
        text      = "Got This!" />
    </article>
