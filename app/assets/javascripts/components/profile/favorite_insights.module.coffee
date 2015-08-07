# @cjsx React.DOM

GlobalState = require('global_state/state')

UserStore   = require('stores/user_store.cursor')

InsightCard = require('components/cards/insight_card')
ListOfCards = require('components/cards/list_of_cards')


# Exports
#
module.exports = React.createClass

  displayName: 'FavoriteInsights'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  propTypes:
    user: React.PropTypes.string.isRequired


  getInitialState: ->
    ready: false


  statics:
    queries:
      user: ->
        """
          User {
            favorite_insights {
              #{InsightCard.getQuery('pin')}
            },
            edges {
              favorite_insights_ids
            }
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('user'), id: @props.user).then =>
      @setState
        ready: true


  # Lifecycle
  #

  componentWillMount: ->
    @cursor =
      user: UserStore.cursor.items.cursor(@props.user)


  componentDidMount: ->
    @fetch()


  # Render insights
  #

  renderInsight: (id) ->
    <InsightCard key={ id } pin={ id } scope='pinboard' />


  renderInsights: ->
    @cursor.user.get('favorite_insights_ids').map @renderInsight


  # Render
  #
  render: ->
    return null unless @state.ready

    <section className="cc-container-common">
      <ListOfCards>
        { @renderInsights().toArray() }
      </ListOfCards>
    </section>
