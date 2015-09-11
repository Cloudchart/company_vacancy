# @cjsx React.DOM

GlobalState     = require('global_state/state')

PinboardStore   = require('stores/pinboard_store')
UserStore       = require('stores/user_store.cursor')

Buttons         = require('components/form/buttons')
AuthButton      = Buttons.AuthButton
SyncButton      = Buttons.SyncButton

PinboardSyncApi = require('sync/pinboard_sync_api')
UserSyncApi     = require('sync/user_sync_api')

cx = React.addons.classSet
isDelayedTaskPerformed = false

SyncApi =
  Pinboard: PinboardSyncApi
  User: UserSyncApi

Store =
  Pinboard: PinboardStore
  User: UserStore

# Main component
#
module.exports = React.createClass

  displayName: 'SharedFollowButton'
  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  propTypes:
    uuid: React.PropTypes.string.isRequired
    type: React.PropTypes.string.isRequired

  statics:
    queries:
      object: (type) ->
        """
          #{type} {
            edges {
              is_followed
            }
          }
        """

      viewer: ->
        """
          Viewer {
            #{AuthButton.getQuery('viewer')}
          }
        """


  # Fetchers
  #
  fetch: ->
    Promise.all([@fetchObject(), @fetchViewer()]).done =>
      @setState ready: true
      # @addCursor 'insight', PinStore.cursor.items.cursor(@props.insight)
      @performDelayedTask()

  fetchObject: ->
    GlobalState.fetch(@getQuery('object', @props.type), id: @props.uuid)

  fetchViewer: ->
    GlobalState.fetch(@getQuery('viewer'))


  # Specifications
  #
  getDefaultProps: ->
    canUnfollow: false

  getInitialState: ->
    ready: false
    sync: false


  # Lifecycle
  #
  componentWillMount: ->
    @cursor =
      object: Store[@props.type].cursor.items.cursor(@props.uuid)

  componentDidMount: ->
    @fetch()


  # Heplers
  #
  performDelayedTask: ->
    return unless cookie = Cookies.get('delayed-task')
    cookie = JSON.parse(cookie)
    if !isDelayedTaskPerformed and cookie.name == 'follow-object' and cookie.uuid == @props.uuid
      isDelayedTaskPerformed = true
      Cookies.remove('delayed-task')
      @syncData() unless @cursor.object.get('is_followed')

  syncData: ->
    action = if @cursor.object.get('is_followed') then 'unfollow' else 'follow'

    SyncApi[@props.type][action](@props.uuid).done =>
      GlobalState.fetchEdges(@props.type, @props.uuid, 'is_followed').done =>
        @setState sync: false


  # Handlers
  #
  handleFollowClick: ->
    @setState sync: true
    @syncData()

  handleAuthClick: ->
    Cookies.set('delayed-task', JSON.stringify({
      name: 'follow-object',
      uuid: @props.uuid
    }))


  # Main render
  #
  render: ->
    return null unless @state.ready

    className = cx
      'cc follow':    true
      'is_followed':  @cursor.object.get('is_followed')

    title = if @cursor.object.get('is_followed')
      if @props.canUnfollow then 'Unfollow' else 'Following'
    else
      'Follow'

    <AuthButton onAuthClick={ @handleAuthClick }>
      <SyncButton
        className   = className
        text        = { title }
        onClick     = { @handleFollowClick }
        sync        = { @state.sync }
        disabled    = { @cursor.object.get('is_followed') and !@props.canUnfollow }
      />
    </AuthButton>
