# @cjsx React.DOM

GlobalState     = require('global_state/state')
cx              = React.addons.classSet

PinboardStore   = require('stores/pinboard_store')

Buttons         = require('components/form/buttons')
AuthButton      = Buttons.AuthButton
SyncButton      = Buttons.SyncButton

SyncApi         = require('sync/pinboard_sync_api')

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

  fetch: (options = {}) ->
    GlobalState.fetch(@getQuery('pinboard'), Object.assign({ id: @props.pinboard }, options)).done =>
      @setState
        ready: true


  # Events
  #

  handleFollowClick: ->
    @setState
      sync: true

    action = if @cursor.pinboard.get('is_followed', false) then 'unfollow' else 'follow'

    SyncApi[action](@props.pinboard).done =>
      GlobalState.fetch(@getQuery('pinboard'), { id: @props.pinboard, force: true }).done =>
        @setState
          sync: false


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

    <AuthButton>
      <SyncButton
        className   = className
        text        = { title }
        onClick     = { @handleFollowClick }
        sync        = { @state.followSync }
        disabled    = { is_followed and !@props.canUnfollow }
      />
    </AuthButton>
