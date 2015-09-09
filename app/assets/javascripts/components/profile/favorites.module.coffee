# @cjsx React.DOM

GlobalState = require('global_state/state')

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
  renderFavorite: (favorite) ->
    switch favorite.favoritable_type
      when 'Pinboard'
        <PinboardCard key = { favorite.favoritable_id } pinboard = { favorite.favoritable_id } />
      when 'User'
        <UserCard key = { favorite.favoritable_id } user = { favorite.favoritable_id } />

  renderFavorites: ->
    Immutable.Seq(@state.user.pinboards_favorites.concat(@state.user.users_favorites))
      .sortBy (favorite) -> favorite.created_at
      .reverse()
      .map @renderFavorite
      .toArray()


  # Main render
  #
  render: ->
    return null unless @state.ready

    <section className="cc-container-common favorites">
      <ListOfCards>
        { @renderFavorites() }
      </ListOfCards>
    </section>
