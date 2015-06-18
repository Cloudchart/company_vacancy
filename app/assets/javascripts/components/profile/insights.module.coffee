# @cjsx React.DOM

GlobalState   = require('global_state/state')
UserStore     = require('stores/user_store.cursor')
PinStore      = require('stores/pin_store')

Insight       = require('components/profile/insight')

# Exports
#
module.exports = React.createClass

  displayName: 'ProfileInsights'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  statics:

    insightsCount: (user_id) ->
      UserStore.cursor.items.getIn([user_id, 'insights'], Immutable.Seq()).size


    queries:

      user: ->
        """
          User {
            edges {
              insights
            }
          }
        """

      list: ->
        """
          User {
            insights {
              #{Insight.getQuery('insight')}
            },
            edges {
              insights
            }
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('user'), { id: @props.user }).then @fetchList


  fetchList: ->
    GlobalState.fetch(@getQuery('list'), { id: @props.user }).then =>
      @setState
        ready: true


  # Specs/Lifecycle
  #

  componentWillMount: ->
    @cursor =
      user:       UserStore.cursor.items.cursor(@props.user)
      insights:   PinStore.cursor.items

    @fetch()


  componentDidMount: ->
    @packery = new Packery @getDOMNode(),
      transitionDuration: '.25s'

    @packery.layout()


  componentDidUpdate: ->
    @packery.layout()


  getInitialState: ->
    ready: false


  # Render
  #

  renderInsight: (item) ->
    <section key={ item.get('id') } className="cloud-column">
      <Insight insight={ item.get('id') } />
    </section>


  renderInsights: ->
    @cursor.user.get('insights', Immutable.Seq())
      .map @renderInsight


  renderPlaceholder: (_, i) ->
    <section key={ @cursor.user.getIn(['insights', i, 'id'], i) } className="cloud-column">
      <section className="pin cloud-card placeholder" />
    </section>


  renderPlaceholders: ->
    Immutable.Repeat('dummy', @constructor.insightsCount(@props.user) || 2)
      .map @renderPlaceholder


  render: ->
    components = if @state.ready then @renderInsights() else @renderPlaceholders()

    <section className="pins cloud-columns cloud-columns-flex">
      { components.toArray() }
    </section>
