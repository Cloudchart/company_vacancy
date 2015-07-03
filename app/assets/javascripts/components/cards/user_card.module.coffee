# @cjsx React.DOM

GlobalState   = require('global_state/state')


UserStore     = require('stores/user_store.cursor')


Letters       = require('utils/letters')


# Exports
#
module.exports = React.createClass

  displayName: 'UserCard'


  propTypes:
    user:     React.PropTypes.string.isRequired
    onClick:  React.PropTypes.func


  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  statics:
    queries:
      user: ->
        """
          User {
            edges {
              nothing
            }
          }
        """

  fetch: ->
    GlobalState.fetch(@getQuery('user'), { id: @props.user }).done =>
      @setState
        ready: true


  getOccupation: ->
    Immutable.Seq([@cursor.user.get('occupation'), @cursor.user.get('company')])
      .filter (value) -> value
      .join ', '


  # Lifecycle
  #

  componentWillMount: ->
    @cursor =
      user: UserStore.cursor.items.get(@props.user)

    @fetch()


  getInitialState: ->
    ready: false


  # Renderers
  #

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
    </div>
