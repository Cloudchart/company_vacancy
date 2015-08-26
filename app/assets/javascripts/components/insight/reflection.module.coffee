# @cjsx React.DOM

# Imports
#

GlobalState = require('global_state/state')
PinStore    = require('stores/pin_store')
UserStore   = require('stores/user_store.cursor')

PinSyncAPI  = require('sync/pin_sync_api')

# Exports
#
module.exports = React.createClass

  displayName: 'InsightReflection'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  propTypes:
    reflection: React.PropTypes.string.isRequired

  getInitialState: ->
    ready:  false
    sync:   false


  statics:
    queries:
      reflection: ->
        """
          Pin {
            user,
            edges {
              users_votes_count,
              is_voted_by_viewer
            }
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('reflection'), id: @props.reflection).then =>
      reflection  = PinStore.cursor.items.cursor(@props.reflection)
      user        = UserStore.cursor.items.cursor(reflection.get('user_id'))

      @addCursor 'reflection',  reflection
      @addCursor 'user',        user

      @setState
        ready: true


  fetchEdges: ->
    GlobalState.fetchEdges('Pin', @props.reflection)


  addOrRemoveVote: ->
    is_voted_by_viewer = @getCursor('reflection').get('is_voted_by_viewer')
    [PinSyncAPI.add_vote, PinSyncAPI.remove_vote][~~is_voted_by_viewer](@props.reflection).then (json) =>
      if json.error == 401
        window.location.href = '/auth/developer/'
      else
        @fetchEdges()
        @setState
          sync: false



  addVote: ->
    PinSyncAPI.add_vote(@props.reflection)


  removeVote: ->
    PinSyncAPI.remove_vote(@props.reflection)


  handleVoteClick: ->
    return if @state.sync

    @setState
      sync: true

    @addOrRemoveVote()


  componentDidMount: ->
    @fetch()


  renderVotes: ->
    iconClassNames = cx
      'fa':           true
      'fa-star':      @getCursor('reflection').get('is_voted_by_viewer')
      'fa-star-o':   !@getCursor('reflection').get('is_voted_by_viewer')
      'fa-spin':      @state.sync

    <aside className="votes" onClick={ @handleVoteClick }>
      <i className={ iconClassNames } />
      { @getCursor('reflection').get('users_votes_count') }
    </aside>


  renderUser: ->
    <a href={ @getCursor('user').get('url') }>
      { @getCursor('user').get('full_name') }
    </a>


  renderContent: ->
    <div className="content">
      <span className="content">
        { @getCursor('reflection').get('content') }
      </span>
      { @renderUser() }
    </div>


  render: ->
    return null unless @state.ready

    <div className="reflection">
      { @renderVotes() }
      { @renderContent() }
    </div>
