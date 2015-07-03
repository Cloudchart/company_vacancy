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


  propTypes:
    pinboard:                   React.PropTypes.string.isRequired
    shouldRenderFollowButton:   React.PropTypes.bool
    onClick:                    React.PropTypes.func
    onUserClick:                React.PropTypes.func


  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  statics:
    queries:
      pinboard: ->
        """
          Pinboard {
            user {
              #{UserCard.getQuery('user')}
            },
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


  getDefaultProps: ->
    shouldRenderFollowButton: true


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


  renderFollowButton: ->
    return null unless @props.shouldRenderFollowButton

    <FollowButton pinboard={ @props.pinboard } />


  renderHeader: ->
    url = @cursor.pinboard.get('url')

    <header>
      <h1>
        <a href={ url } onClick={ @props.onClick } className="see-through">
          { @cursor.pinboard.get('title') }
          { @renderAccessRightsIcon() }
        </a>
        { @renderFollowButton() }
      </h1>
      <h2>
        <a href={ url } onClick={ @props.onClick } className="see-through">
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
      <UserCard user={ @cursor.pinboard.get('user_id') } onClick={ @props.onUserClick } />
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
