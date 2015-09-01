# @cjsx React.DOM

GlobalState = require('global_state/state')

PinStore = require('stores/pin_store')

NotificationsPushApi = require('push_api/notifications_push_api')

# cx = React.addons.classSet
DOMAIN_RE = /^http[s]{0,1}\:\/\/([^\/]+)/i


# Main component
#
module.exports = React.createClass

  displayName: 'InsightOrigin'
  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  propTypes:
    pin: React.PropTypes.string.isRequired

  statics:
    queries:
      pin: ->

        query = """
          edges {
            is_origin_domain_allowed,
            diffbot_response_data
          }
        """

        """
          Pin {
            #{query},
            parent {
              #{query}
            }
          }
        """


  # Fetchers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('pin'), { id: @props.pin }).then (json) =>
      @setState
        ready: true
        pin: PinStore.get(@props.pin).toJS()


  # Component Specifications
  #
  # getDefaultProps: ->

  getInitialState: ->
    ready: false


  # Lifecycle Methods
  #
  # componentWillMount: ->

  componentDidMount: ->
    @fetch()

  # componentWillUnmount: ->


  # Helpers
  #
  # getSomething: ->


  # Handlers
  #
  handleOriginClick: (event) ->
    NotificationsPushApi.post_to_slack('clicked_on_external_url',
      pin_id: @state.pin.uuid
      external_url: @state.pin.origin
    )


  # Renderers
  #
  renderTitle: ->
    return null unless @state.pin.diffbot_response_data
    return null unless title = @state.pin.diffbot_response_data.title

    <span className="title">{ title + ', ' }</span>

  renderEstimation: ->
    return null unless @state.pin.diffbot_response_data
    return null unless estimated_time = @state.pin.diffbot_response_data.estimated_time

    <span className="estimation" style={ 'white-space': 'nowrap' } >
      <span> &mdash; </span>
      <i className="fa fa-clock-o" style = { 'margin-right': '5px' } />
      { moment.duration(estimated_time, 'seconds').humanize(); }
    </span>


  # Main render
  #
  render: ->
    return null unless @state.ready
    return null unless @state.pin.origin && @state.pin.is_origin_domain_allowed
    return null unless (parts = DOMAIN_RE.exec(@state.pin.origin)) and parts.length == 2
    [_, domain] = parts

    <div className="origin">
      { @renderTitle() }

      <a href={ @state.pin.origin } target="_blank" onClick={ @handleOriginClick }>
        { domain }
      </a>

      { @renderEstimation() }
    </div>
