# @cjsx React.DOM

GlobalState       = require('global_state/state')


# Stores
#
PinboardStore     = require('stores/pinboard_store')
UserStore         = require('stores/user_store.cursor')

# Components
#
PinboardCard  = require('components/cards/pinboard_card')
ListOfCards   = require('components/cards/list_of_cards')


# Exports
#
module.exports = React.createClass


  displayName: 'UserPinboards'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      pinboards: ->
        """
          User {
            related_pinboards {
              #{PinboardCard.getQuery('pinboard')}
            },
            edges {
              related_pinboards
            }
          }
        """

  propTypes:
    user_id:     React.PropTypes.string


  getInitialState: ->
    ready: true


  fetch: ->
    GlobalState.fetch(@getQuery('pinboards'), id: @props.user_id).then =>
      @setState
        ready: true


  # Lifecyle methods
  #
  componentWillMount: ->
    @cursor =
      user: UserStore.cursor.items.cursor(@props.user_id)


  componentDidMount: ->
    @fetch()


  renderPinboard: (pinboard) ->
    <PinboardCard key={ pinboard.id } pinboard={ pinboard.id } />


  renderPinboards: ->
    @cursor.user.get('related_pinboards')
      .map (pinboard) -> PinboardStore.get(pinboard.get('id')).toJS()
      .sortBy (pinboard) -> +!pinboard.is_invited + pinboard.title
      .map @renderPinboard
      .toArray()


  render: ->
    return null unless @state.ready

    <section className="cc-container-common">
      <ListOfCards>
        { @renderPinboards() }
      </ListOfCards>
    </section>
