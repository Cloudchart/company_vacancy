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
    user: null


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
        user: UserStore.get(@props.user).toJS()


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
    className = cx
      transparent: !@cursor.user.get('favorite_insights_ids').contains(id)

    <InsightCard key={ id } pin={ id } scope='pinboard' className={ className } />


  renderInsights: ->
    @state.user.favorite_insights_ids.map @renderInsight


  # Render
  #
  render: ->
    return null unless @state.user

    <section className="cc-container-common">
      <ListOfCards>
        { @renderInsights() }
      </ListOfCards>
    </section>
