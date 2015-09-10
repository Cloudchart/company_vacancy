# @cjsx React.DOM

GlobalState = require('global_state/state')

PinboardStore = require('stores/pinboard_store')
UserStore = require('stores/user_store.cursor')

ListOfCards = require('components/cards/list_of_cards')
PinboardCard = require('components/cards/pinboard_card')
UserCard = require('components/cards/user_card')

# cx = React.addons.classSet


# Main component
#
module.exports = React.createClass

  displayName: 'ProfileFavorites'
  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  propTypes:
    user: React.PropTypes.string.isRequired

  statics:
    queries:
      user: ->
        """
          User {
            favorite_pinboards {
              #{PinboardCard.getQuery('pinboard')}
            },
            favorite_users,
            edges {
              pinboards_favorites,
              users_favorites
            }
          }
        """


  # Fetchers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('user'), { id: @props.user }).then =>
      @setState
        ready: true
        user: UserStore.get(@props.user).toJS()


  # Component Specifications
  #
  # getDefaultProps: ->

  getInitialState: ->
    ready: false


  # Lifecycle Methods
  #
  # componentWillMount: ->

  componentDidMount: ->
    @fetch()

  # componentWillUnmount: ->


  # Helpers
  #
  # getSomething: ->


  # Handlers
  #
  # handleThingClick: (event) ->


  # Renderers
  #
  renderUsers: ->
    return null unless @state.user.users_favorites.length > 0

    <section className="cc-container-common favorites users">
      <header>
        <h1>People</h1>
      </header>

      <ListOfCards>
        { @renderUserCards() }
      </ListOfCards>
    </section>

  renderUserCards: ->
    users = @state.user.users_favorites.map (favorite) -> UserStore.get(favorite.favoritable_id)

    Immutable.Seq(users)
      .sortBy (user) -> user.get('full_name')
      .map (user) -> <UserCard key={ user.get('uuid') } user={ user.get('uuid') } />
      .toArray()

  renderPinboards: ->
    return null unless @state.user.pinboards_favorites.length > 0

    <section className="cc-container-common">
      <header>
        <h1>Collections</h1>
      </header>

      <ListOfCards>
        { @renderPinboardCards() }
      </ListOfCards>
    </section>

  renderPinboardCards: ->
    pinboards = @state.user.pinboards_favorites.map (favorite) -> PinboardStore.get(favorite.favoritable_id)

    Immutable.Seq(pinboards)
      .sortBy (pinboard) -> pinboard.get('title')
      .map (pinboard) -> <PinboardCard key={ pinboard.get('uuid') } pinboard={ pinboard.get('uuid') } />
      .toArray()


  # Main render
  #
  render: ->
    return null unless @state.ready

    <section className="cc-container-common">
      { @renderUsers() }
      { @renderPinboards() }
    </section>
