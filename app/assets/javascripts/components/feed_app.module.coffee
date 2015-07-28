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

  # propTypes:
    # some_object: React.PropTypes.object.isRequired

  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  getInitialState: ->
    date:   null
    ready:  false


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
        ready:  true


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
  renderEmptyFeed: ->
    <span>Fuck off</span>


  # Main render
  #
  render: ->
    return null unless @state.ready

    <div className="feed-container">
      <h1>{ @state.date.format('LL') }</h1>
      <h2>{ "Hey, tell us what is the most inspirational insight you saw on the web. Suggest insight to our
readers collection." }</h2>
      <MainList date={ @props.date.format('YYYY-MM-DD') } />
    </div>
