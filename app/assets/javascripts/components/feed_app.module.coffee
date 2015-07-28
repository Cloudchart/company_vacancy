# @cjsx React.DOM

GlobalState = require('global_state/state')
MainList = require('components/feed/main_list')


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


  getInitialState: ->
    date: null


  statics:
    queries:
      viewer: ->
        """
          Viewer {
            edges {
              next_feed_date
            }
          }
        """


  fetch: (date) ->
    if date
      date = moment(date)
      date = moment() unless date.isValid()
      date = date.format('YYYY-MM-DD')

    GlobalState.fetch(@getQuery('viewer'), { force: true, params: { date: date } }).then (json) =>
      @setState
        date: date


  # Lifecycle Methods
  #
  # componentWillMount: ->

  componentDidMount: ->
    @fetch(@props.date)

  # componentWillUnmount: ->


  # Fetchers
  #
  # fetch: ->


  # Helpers
  #
  # getSomething: ->


  # Handlers
  #
  # handleThingClick: (event) ->


  # Renderers
  #
  # renderEmptyFeed: ->


  # Main render
  #
  render: ->
    return null unless @state.date

    <div className="feed-container">
      <h1>{ moment(@state.date).format('LL') }</h1>
      <h2>{ "Hey, tell us what is the most inspirational insight you saw on the web. Suggest insight to our
readers collection." }</h2>
      <MainList date = { moment(@state.date).format('YYYY-MM-DD') } />
    </div>
