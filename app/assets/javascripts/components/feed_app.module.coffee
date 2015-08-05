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
    loaded_dates:         0
    pending_dates:        0
    dates:                []

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


  # Helpers
  #
  shouldLoadNextDate: ->
    @refs['loader'].getDOMNode().getBoundingClientRect().top < window.innerHeight


  loadNextDate: ->
    clearTimeout @load_next_date_timeout
    @load_next_date_timeout = setTimeout =>
      return unless @state.pending_dates == 0 and @shouldLoadNextDate()
      @setState
        pending_dates: @state.pending_dates + 1
    , 250


  # Handlers
  #

  handleResize: ->
    @loadNextDate()


  handleScroll: ->
    @loadNextDate()


  handleDayLoad: ->
    @setState
      pending_dates:  @state.pending_dates - 1
      loaded_dates:   @state.loaded_dates + 1

    @loadNextDate()


  # Lifecycle Methods
  #

  componentWillMount: ->
    @cursor =
      viewer: UserStore.me()

    @setState
      pending_dates: 1


  componentDidMount: ->
    window.addEventListener('resize', @handleResize)
    window.addEventListener('scroll', @handleScroll)
    @fetch()


  componentWillUnmount: ->
    window.removeEventListener('resize', @handleResize)
    window.removeEventListener('scroll', @handleScroll)


  # Renderer Days
  #

  renderDay: (date) ->
    <DailyFeed key={ date } date={ moment(date).toDate() } onDone={ @handleDayLoad } />


  renderDays: ->
    return unless feed_dates = @cursor.viewer.get('feed_dates', null)

    feed_dates
      .reverse()
      .take(@state.loaded_dates + @state.pending_dates)
      .map @renderDay
      .toArray()



  # Main render
  #
  render: ->
    <section className="feed-days-wrapper">
      { @renderDays() }
      <span ref='loader' />
    </section>
