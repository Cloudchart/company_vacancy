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

    SyncApi.follow(@props.pinboard).done =>
      GlobalState.fetch(@getQuery('pinboard'), { id: @props.pinboard, force: true }).done =>
        @setState
          sync: false


  # Lifecycle
  #

  componentWillMount: ->
    @cursor =
      pinboard: PinboardStore.cursor.items.cursor(@props.pinboard)

    @fetch()

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

    <AuthButton>
      <SyncButton
        className   = className
        text        = { if is_followed then "Following" else "Follow" }
        onClick     = { @handleFollowClick }
        sync        = { @state.followSync }
        disabled    = is_followed
      />
    </AuthButton>
