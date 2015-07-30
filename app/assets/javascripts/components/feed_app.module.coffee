# @cjsx React.DOM

GlobalState = require('global_state/state')
MainList = require('components/feed/main_list')
UserStore = require('stores/user_store.cursor')


# Utils
#
# cx = React.addons.classSet


# Main component
#
module.exports = React.createClass

  displayName: 'FeedApp'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  # propTypes:
    # some_object: React.PropTypes.object.isRequired

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
  fetch: (date) ->
    if date
      date = moment(date)
      date = moment() unless date.isValid()
      date = date.format('YYYY-MM-DD')

    GlobalState.fetch(@getQuery('viewer')).then (json) =>
      if closest_date = @getClosestDate(date)
        @setState
          dates: @state.dates.concat(closest_date)
      else
        @setState({})


  # Component Specifications
  #
  getDefaultProps: ->
    me: UserStore.me()

  getInitialState: ->
    dates: []


  # Lifecycle Methods
  #
  # componentWillMount: ->

  componentDidMount: ->
    @fetch(@props.date)

  # componentWillUnmount: ->


  # Helpers
  #
  getNextDate: ->
    date = @state.dates[@state.dates.length - 1]

    @props.me.get('feed_dates', [])
      .filter (d) -> d < date
      .sort()
      .last()

  getClosestDate: (date) ->
    @props.me.get('feed_dates', [])
      .filter (d) -> d <= date
      .sort()
      .last()


  # Handlers
  #
  handleNextClick: (date, event) ->
    event.preventDefault()

    @setState
      dates: @state.dates.concat(date)


  # Renderers
  #
  renderDailyList: ->
    @state.dates.map (date) ->
      [
        <section className="cc-container-common" key={ date }>
          <header>
            <h1>{ moment(date).format('LL') }</h1>
          </header>
        </section>
        <MainList date={ moment(date).format('YYYY-MM-DD') } />
      ]

  renderNextDateLink: ->
    return unless nextDate = @getNextDate()

    <a href="#" onClick={ @handleNextClick.bind(null, nextDate) }>
      Go west!
    </a>


  # Main render
  #
  render: ->
    return null if @state.dates.length == 0

    <div className="feed-container">
      { @renderDailyList() }
      <footer>
        { @renderNextDateLink() }
      </footer>
    </div>
