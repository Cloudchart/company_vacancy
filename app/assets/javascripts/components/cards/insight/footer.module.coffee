# @cjsx React.DOM

GlobalState         = require('global_state/state')

PinStore            = require('stores/pin_store')

EditPinButton       = require('components/pinnable/edit_pin_button')
ShareInsightButton  = require('components/insight/share_button')

cx = React.addons.classSet


# Main component
#
module.exports = React.createClass

  displayName: 'InsightCardFooter'

  propTypes:
    pin: React.PropTypes.string.isRequired

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:
    queries:
      pin: ->
        """
          Pin {
            #{ShareInsightButton.getQuery('pin')}
          }
        """


  # Component Specifications
  #
  # getDefaultProps: ->

  getInitialState: ->
    ready: false
    pin: {}


  # Lifecycle Methods
  #
  # componentWillMount: ->

  componentDidMount: ->
    @fetch()

  # componentWillUnmount: ->


  # Fetchers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('pin'), { id: @props.pin }).then =>
      @setState
        ready: true
        pin: PinStore.get(@props.pin).toJS()


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
    return null unless @state.ready

    <footer>
      <ul className="round-buttons">
        <EditPinButton uuid = { @state.pin.uuid } />
        <ShareInsightButton pin = { @state.pin } />
        <li className="round-button">
          <i className="fa fa-star"></i>
        </li>
      </ul>
    </footer>
