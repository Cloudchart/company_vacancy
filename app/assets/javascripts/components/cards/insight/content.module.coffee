# @cjsx React.DOM

GlobalState = require('global_state/state')

PinStore = require('stores/pin_store')
UserStore = require('stores/user_store.cursor')


# Main component
#
module.exports = React.createClass

  displayName: "InsightContent"

  propTypes:
    pin:      React.PropTypes.string.isRequired
    onUpdate: React.PropTypes.func

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:
    queries:
      pin: ->
        """
          Pin {
            user_id,
            user
          }
        """


  # Component Specifications
  #
  getDefaultProps: ->
    onUpdate: ->


  getInitialState: ->
    pin: {}
    user: {}
    ready: false


  # Lifecycle Methods
  #
  # componentWillMount: ->

  componentDidMount: ->
    @fetch()

  componentDidUpdate: ->
    @props.onUpdate()


  # Fetchers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('pin'), { id: @props.pin }).then =>
      pin = PinStore.get(@props.pin).toJS()
      user = UserStore.get(pin.user_id).toJS()
      @setState
        ready: true
        pin: pin
        user: user


  # Renderers
  #
  renderUser: ->
    <a href={ @state.user.url }>
      { @state.user.full_name }
    </a>


  # Main Render
  #
  render: ->
    return null unless @state.ready

    <section className="content" onClick={ @props.onClick }>
      <span className="content">
        { @state.pin.content }
      </span>
      <span> &mdash; </span>
      { @renderUser() }
    </section>
