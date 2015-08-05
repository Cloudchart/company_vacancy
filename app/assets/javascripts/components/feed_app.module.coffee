# @cjsx React.DOM

GlobalState   = require('global_state/state')

DailyFeed     = require('components/feed/daily')

UserStore     = require('stores/user_store.cursor')


# Main component
#
module.exports = React.createClass

  displayName: 'FeedApp'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  getInitialState: ->
    dates: []

  statics:
    queries:
      viewer: ->
        """
          Viewer {
            edges {
              feed_dates
            }
          }
        """


  # Fetchers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('viewer'))


  # Lifecycle Methods
  #

  componentWillMount: ->
    @cursor =
      viewer: UserStore.me()


  componentDidMount: ->
    @fetch()


  # Renderer Days
  #

  renderDay: (date) ->
    <DailyFeed key={ date } date={ moment(date).toDate() } />


  renderDays: ->
    return unless feed_dates = @cursor.viewer.get('feed_dates', null)

    feed_dates
      .reverse()
      .take(1)
      .map @renderDay
      .toArray()



  # Main render
  #
  render: ->
    <section className="feed-days-wrapper">
      { @renderDays() }
    </section>
