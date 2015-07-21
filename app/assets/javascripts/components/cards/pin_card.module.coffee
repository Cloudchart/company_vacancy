# @cjsx React.DOM

GlobalState = require('global_state/state')


PinStore    = require('stores/pin_store')
UserStore   = require('stores/user_store.cursor')


# Exports
#
module.exports = React.createClass

  displayName: "PinCard"


  propTypes:
    pin:        React.PropTypes.string.isRequired
    className:  React.PropTypes.string
    onUpdate:   React.PropTypes.func


  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  statics:
    queries:
      pin: ->
        """
          Pin {
            user {
            }
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('pin'), { id: @props.pin }).then =>
      pin   = PinStore.get(@props.pin).toJS()
      user  = UserStore.get(pin.user_id).toJS()
      @setState
        ready:  true
        pin:    pin
        user:   user


  # Lifecycle
  #


  componentWillMount: ->
    @cursor =
      pin: PinStore.cursor.items.cursor(@props.pin)


  componentDidMount: ->
    @fetch()


  componentDidUpdate: ->
    @props.onUpdate()


  getDefaultProps: ->
    className:  ''
    onUpdate:   ->


  getInitialState: ->
    ready:  false
    pin:    {}
    user:   {}


  # Main Render
  #

  renderContent: ->
    <span className="content">
      { @state.pin.content }
    </span>


  renderUser: ->
    <a href={ @state.user.url }>
      { @state.user.full_name }
    </a>


  render: ->
    return null unless @state.ready

    <div className="pin-card cloud-card #{@props.className}" onClick={ @props.onClick }>
      { @renderContent() }
      <span> &mdash; </span>
      { @renderUser() }
    </div>
