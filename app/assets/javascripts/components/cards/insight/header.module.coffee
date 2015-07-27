# @cjsx React.DOM

GlobalState = require('global_state/state')

PinStore = require('stores/pin_store')
UserStore = require('stores/user_store.cursor')
PinboardStore = require('stores/pinboard_store')


# Utils
#
# cx = React.addons.classSet


# Main component
#
module.exports = React.createClass

  displayName: 'PinCardHeader'

  propTypes:
    pin: React.PropTypes.string.isRequired

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:
    queries:
      pin: ->
        """
          Pin {
            pinboard,
            user
          }
        """


  # Component Specifications
  #
  # getDefaultProps: ->

  getInitialState: ->
    ready: false
    pin: {}
    user: {}
    pinboard: {}


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
      pin = PinStore.get(@props.pin).toJS()

      @setState
        ready: true
        pin: pin
        user: UserStore.get(pin.user_id).toJS()
        pinboard: PinboardStore.get(pin.pinboard_id).toJS() if pin.pinboard_id


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
    content = if @state.pin.parent_id && @state.pin.content && @state.pin.pinboard_id
      [
        <i key=1 className="fa fa-comment-o" />
        <span key=2 >{ "#{@state.user.full_name}: " }</span>
        <span key=3 >{ @state.pin.content }</span>
        <span key=4 >{ @state.pinboard.title }</span>
      ]
    else if @state.pin.pinboard_id
      <span>{ @state.pinboard.title }</span>

    <header>{ content }</header>
