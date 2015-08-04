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

  loadNextDate: (date) ->
    @setState
      dates: @state.dates.concat(date)



  loadPage: ->
    return unless @refs['next-page-link'] && element = @refs['next-page-link'].getDOMNode()
    if element.getBoundingClientRect().top < window.innerHeight
      @loadNextDate(element.dataset.nextDate)



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
    window.addEventListener('scroll', @handleScroll)


  componentWillUnmount: ->
    window.removeEventListener('scroll', @handleScroll)


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

  handleScroll: ->
    clearTimeout @scrollTimeout
    @scrollTimeout = setTimeout =>
      @loadPage()
    , 250


  handleNextClick: (date, event) ->
    event.preventDefault()

    @loadNextDate(date)


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
    <a ref="next-page-link" href="#" data-next-date={ nextDate } onClick={ @handleNextClick.bind(null, nextDate) }>
      <i className="fa fa-spin fa-refresh" />
    </a>


  # Main render
  #
  render: ->
    return null if @state.dates.length == 0

    <div className="feed-container">
      { @renderDailyList() }
      <footer style={ fontSize: '40px', margin: '20px auto', width: '100px', textAlign: 'center' }>
        { @renderNextDateLink() }
      </footer>
    </div>
