# @cjsx React.DOM

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
  # mixins: []
  # statics: {}


  # Component Specifications
  #
  # getDefaultProps: ->

  getInitialState: ->
    date = moment(@props.date, 'YYYY-MM-DD')
    date = moment() unless date.isValid()
    date: date


  # Lifecycle Methods
  #
  # componentWillMount: ->
  # componentDidMount: ->
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
  # renderSomething: ->


  # Main render
  #
  render: ->
    <div className="feed-container">
      <h1>{ @state.date.format('LL') }</h1>
      <h2>{ "Hey, tell us what is the most inspirational insight you saw on the web. Suggest insight to our
readers collection." }</h2>
      <MainList date={ @state.date.format('YYYY-MM-DD') } />
    </div>
