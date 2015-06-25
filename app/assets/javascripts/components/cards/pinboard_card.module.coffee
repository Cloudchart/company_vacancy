# @cjsx React.DOM


GlobalState     = require('global_state/state')
cx              = React.addons.classSet

SyncApi         = require('sync/pinboard_sync_api')

PinboardStore   = require('stores/pinboard_store')

UserCard        = require('components/cards/user_card')
Buttons         = require('components/form/buttons')
AuthButton      = Buttons.AuthButton
SyncButton      = Buttons.SyncButton

pluralize       = require('utils/pluralize')

Placeholder     =
  <div className="pinboard-card placeholder" />

# Exports
#
module.exports = React.createClass


  displayName: 'PinboardCard'


  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  statics:
    queries:
      pinboard: ->
        """
          Pinboard {
            user,
            edges {
              readers_count,
              pins_count,
              is_followed
            }
          }
        """

      pinboard_follow_state: ->
        """
          Pinboard {
            edges {
              is_followed
            }
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('pinboard'), { id: @props.pinboard }).done =>
      @setState
        ready: true


  # Lifecycle
  #

  componentWillMount: ->
    @cursor =
      pinboard: PinboardStore.cursor.items.cursor(@props.pinboard)

    @fetch()


  getInitialState: ->
    ready:        false
    followSync:   false


  # Events
  #

  handleFollowClick: ->
    @setState
      followSync: true

    SyncApi.follow(@props.pinboard).done =>
      GlobalState.fetch(@getQuery('pinboard_follow_state'), { id: @props.pinboard, force: true }).done =>
        @setState
          followSync: false


  # Renderers
  #

  renderAccessRightsIcon: ->
    className = cx
      'fa':             true
      'fa-lock':        @cursor.pinboard.get('access_rights') is 'private'
      'fa-eye-slash':   @cursor.pinboard.get('access_rights') is 'protected'

    <i className={ className } />


  renderFollowButton: ->
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


  renderHeader: ->
    url = @cursor.pinboard.get('url')

    <header>
      <h1>
        <a href={ url } className="see-through">
          { @cursor.pinboard.get('title') }
          { @renderAccessRightsIcon() }
        </a>
        { @renderFollowButton() }
      </h1>
      <h2>
        <a href={ url } className="see-through">
          { @cursor.pinboard.get('description') }
        </a>
      </h2>
    </header>


  renderCounters: ->
    <ul className="statistics">
      <li>
        { pluralize(@cursor.pinboard.get('readers_count', 0), ' Follower', ' Followers') }
      </li>
      <li>
        { pluralize(@cursor.pinboard.get('pins_count', 0), ' Insight', ' Insights') }
      </li>
    </ul>


  renderFooter: ->
    <footer>
      <UserCard user={ @cursor.pinboard.get('user_id') } />
      { @renderCounters() }
    </footer>


  # Main render
  #
  render: ->
    return Placeholder unless @state.ready

    <div className="pinboard-card">
      { @renderHeader() }
      { @renderFooter() }
    </div>
