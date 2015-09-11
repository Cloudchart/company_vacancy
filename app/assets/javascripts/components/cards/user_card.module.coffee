# @cjsx React.DOM

GlobalState   = require('global_state/state')

UserStore     = require('stores/user_store.cursor')

FollowButton  = require('components/shared/follow_button')

Letters       = require('utils/letters')

# Main component
#
module.exports = React.createClass

  displayName: 'UserCard'
  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  propTypes:
    user: React.PropTypes.string.isRequired
    onClick: React.PropTypes.func
    shouldRenderFollowButton: React.PropTypes.bool

  statics:
    queries:
      user: ->
        """
          User {
            #{FollowButton.getQuery('object', 'User')}
          }
        """

  fetch: ->
    GlobalState.fetch(@getQuery('user'), { id: @props.user }).done =>
      @setState
        ready: true


  # Component specifications
  #
  getDefaultProps: ->
    shouldRenderFollowButton: true

  getInitialState: ->
    ready: false


  # Lifecycle
  #
  componentWillMount: ->
    @cursor =
      user: UserStore.cursor.items.cursor(@props.user)

  componentDidMount: ->
    @fetch()


  # Helpers
  #
  getOccupation: ->
    Immutable.Seq([@cursor.user.get('occupation'), @cursor.user.get('company')])
      .filter (value) -> value
      .join ', '


  # Renderers
  #
  renderFollowButton: ->
    return null unless @props.shouldRenderFollowButton

    [
      <div key="spacer" className="spacer"></div>
      <FollowButton key="follow_button" uuid={ @props.user } type={ 'User' } />
    ]

  renderAvatar: ->
    avatar_url  = @cursor.user.get('avatar_url')
    url         = @cursor.user.get('url')
    style       =
      backgroundImage: if avatar_url then "url(#{avatar_url})" else "none"

    <a href={ url } onClick={ @props.onClick } className="see-through">
      <figure style={ style }>
        <figcaption>
          { Letters(@cursor.user.get('full_name')) unless avatar_url }
        </figcaption>
      </figure>
    </a>

  renderCredentials: ->
    url = @cursor.user.get('url')

    <section>
      <p className="name">
        <a href={ url } onClick={ @props.onClick } className="see-through">
          { @cursor.user.get('full_name') }
        </a>
      </p>
      <p className="occupation">
        <a href={ url } onClick={ @props.onClick } className="see-through">
          { @getOccupation() }
        </a>
      </p>
    </section>


  # Main Render
  #
  render: ->
    return null unless @state.ready

    <div className="user-card">
      { @renderAvatar() }
      { @renderCredentials() }
      { @renderFollowButton() }
    </div>
