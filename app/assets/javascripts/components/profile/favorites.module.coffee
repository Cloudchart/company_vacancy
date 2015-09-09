# @cjsx React.DOM

GlobalState = require('global_state/state')

UserStore = require('stores/user_store.cursor')

ListOfCards = require('components/cards/list_of_cards')
PinboardCard = require('components/cards/pinboard_card')

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
            edges {
              favorite_pinboard_ids
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
  renderFavorites: ->
    @state.user.favorite_pinboard_ids.map (id) ->
      <PinboardCard key = { id } pinboard = { id } />


  # Main render
  #
  render: ->
    return null unless @state.ready

    <section className="cc-container-common">
      <ListOfCards>
        { @renderFavorites() }
      </ListOfCards>
    </section>
