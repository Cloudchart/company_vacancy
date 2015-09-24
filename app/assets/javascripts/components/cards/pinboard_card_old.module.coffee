# @cjsx React.DOM


GlobalState     = require('global_state/state')
cx              = React.addons.classSet

PinboardStore   = require('stores/pinboard_store')
UserStore       = require('stores/user_store.cursor')

UserCard        = require('components/cards/user_card')
FollowButton    = require('components/shared/follow_button')
InviteActions   = require('components/roles/invite_actions')

pluralize       = require('utils/pluralize')

Placeholder     =
  <div className="pinboard-card placeholder" />

# Exports
#
module.exports = React.createClass


  displayName: 'PinboardCard'


  propTypes:
    pinboard:                   React.PropTypes.string.isRequired
    className:                  React.PropTypes.string
    shouldRenderFollowButton:   React.PropTypes.bool
    onClick:                    React.PropTypes.func
    onUserClick:                React.PropTypes.func
    onUpdate:                   React.PropTypes.func


  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  statics:
    queries:
      pinboard: ->
        """
          Pinboard {
            #{InviteActions.getQuery('owner', 'Pinboard')},
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


  componentDidMount: ->
    @fetch()


  componentDidUpdate: ->
    @props.onUpdate()


  getDefaultProps: ->
    className:                ''
    shouldRenderFollowButton: true
    onUpdate:                 ->


  getInitialState: ->
    ready: false


  # Renderers
  #
  renderUserCard: ->
    user_id = @cursor.pinboard.get('user_id')
    return <div></div> if user_id == UserStore.me().get('uuid')

    <UserCard
      user={ @cursor.pinboard.get('user_id') }
      onClick={ @props.onUserClick }
      shouldRenderFollowButton=false
    />

  renderAccessRightsIcon: ->
    className = cx
      'fa':             true
      'fa-lock':        @cursor.pinboard.get('access_rights') is 'private'
      'fa-eye-slash':   @cursor.pinboard.get('access_rights') is 'protected'

    <i className={ className } />

  renderFollowButton: ->
    return null unless @props.shouldRenderFollowButton
    <FollowButton uuid={ @props.pinboard } type={ 'Pinboard' } />

  renderHeader: ->
    url = @cursor.pinboard.get('url')

    <header>
      <h1>
        <a href={ url } onClick={ @props.onClick } className="see-through dependent">
          { @cursor.pinboard.get('title') }
          { @renderAccessRightsIcon() }
        </a>
        { @renderFollowButton() }
      </h1>
      <h2>
        <a href={ url } onClick={ @props.onClick } className="see-through dependent">
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
      { @renderUserCard() }
      { @renderCounters() }
    </footer>


  # Main render
  #
  render: ->
    return Placeholder unless @state.ready

    <div className="pinboard-card #{@props.className}">
      { @renderHeader() }
      { @renderFooter() }
      <InviteActions ownerId = { @props.pinboard } ownerType = { 'Pinboard' } />
    </div>
