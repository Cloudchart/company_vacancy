# @cjsx React.DOM

GlobalState       = require('global_state/state')


# Stores
#
PinboardStore     = require('stores/pinboard_store')
UserStore         = require('stores/user_store.cursor')

# Components
#
PinboardCard  = require('components/cards/pinboard_card')
PinboardList  = require('components/pinboards/lists/base')


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
            available_pinboards {
              #{PinboardCard.getQuery('pinboard')}
            },
            edges {
              available_pinboards_ids
            }
          }
        """

  propTypes:
    user_id: React.PropTypes.string


  getInitialState: ->
    ready: false


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
    @cursor.user.get('available_pinboards_ids')
      .map (id) -> PinboardStore.get(id).toJS()
      .sortBy (pinboard) -> +!pinboard.is_invited + pinboard.title
      .map @renderPinboard
      .toArray()


  render: ->
    return null unless @state.ready

    <section className="cc-container-common">
      <PinboardList>
        { @renderPinboards() }
      </PinboardList>
    </section>
