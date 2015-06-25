# @cjsx React.DOM


GlobalState     = require('global_state/state')
cx              = React.addons.classSet

PinboardStore   = require('stores/pinboard_store')

UserCard        = require('components/cards/user_card')
FollowButton    = require('components/pinboards/follow_button')

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
    ready: false


  # Renderers
  #

  renderAccessRightsIcon: ->
    className = cx
      'fa':             true
      'fa-lock':        @cursor.pinboard.get('access_rights') is 'private'
      'fa-eye-slash':   @cursor.pinboard.get('access_rights') is 'protected'

    <i className={ className } />


  renderHeader: ->
    url = @cursor.pinboard.get('url')

    <header>
      <h1>
        <a href={ url } className="see-through">
          { @cursor.pinboard.get('title') }
          { @renderAccessRightsIcon() }
        </a>
        <FollowButton pinboard={ @props.pinboard } />
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
