# @cjsx React.DOM

GlobalState     = require('global_state/state')
cx              = React.addons.classSet

PinboardStore   = require('stores/pinboard_store')

Buttons         = require('components/form/buttons')
AuthButton      = Buttons.AuthButton
SyncButton      = Buttons.SyncButton

SyncApi         = require('sync/pinboard_sync_api')

isDelayedTaskPerformed = false

# Exports
#
module.exports = React.createClass

  displayName: 'PinboardFollowButton'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:
    queries:
      pinboard: ->
        """
          Pinboard {
            edges {
              readers_count,
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


  fetchPinboard: (options = {}) ->
    GlobalState.fetch(@getQuery('pinboard'), Object.assign({ id: @props.pinboard }, options))


  fetchViewer: (options = {}) ->
    GlobalState.fetch(@getQuery('viewer'), options)


  fetch: (options = {}) ->
    Promise.all([@fetchPinboard(options), @fetchViewer(options)]).done =>
      @setState
        ready: true
      @performDelayedTask()


  # Utils
  #

  performDelayedTask: ->
    return unless cookie = Cookies.get('delayed-task')
    cookie = JSON.parse(cookie)
    if !isDelayedTaskPerformed and cookie.name == 'follow-pinboard' and cookie.pinboard == @props.pinboard
      isDelayedTaskPerformed = true
      Cookies.remove('delayed-task')
      @syncData() unless @cursor.pinboard.get('is_followed', false)


  # Events
  #

  handleFollowClick: ->
    @setState
      sync: true

    @syncData()


  syncData: ->
    action = if @cursor.pinboard.get('is_followed', false) then 'unfollow' else 'follow'

    SyncApi[action](@props.pinboard).done =>
      GlobalState.fetch(@getQuery('pinboard'), { id: @props.pinboard, force: true }).done =>
        @setState
          sync: false


  handleAuthClick: ->
    Cookies.set('delayed-task', JSON.stringify({
      name:     'follow-pinboard',
      pinboard: @props.pinboard
    }))


  # Lifecycle
  #

  componentWillMount: ->
    @cursor =
      pinboard: PinboardStore.cursor.items.cursor(@props.pinboard)

    @fetch()


  getDefaultProps: ->
    canUnfollow: false


  getInitialState: ->
    ready:  false
    sync:   false


  # Render
  #
  render: ->
    return null unless @state.ready

    is_followed = @cursor.pinboard.get('is_followed')

    className = cx
      'cc follow':    true
      'is_followed':  is_followed

    title = if is_followed
      if @props.canUnfollow then 'Unfollow' else 'Following'
    else
      'Follow'

    console.log 'Pinboard', (is_followed and !@props.canUnfollow)
    <AuthButton onAuthClick={ @handleAuthClick }>
      <SyncButton
        className   = className
        text        = { title }
        onClick     = { @handleFollowClick }
        sync        = { @state.sync }
        disabled    = { is_followed and !@props.canUnfollow }
      />
    </AuthButton>
