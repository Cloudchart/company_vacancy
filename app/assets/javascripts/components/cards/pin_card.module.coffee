# @cjsx React.DOM

GlobalState = require('global_state/state')

PinStore = require('stores/pin_store')
UserStore = require('stores/user_store.cursor')

Header = require('components/cards/pin/header')
Footer = require('components/cards/pin/footer')


# Main component
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
            user
          }
        """


  # Component Specifications
  #
  getDefaultProps: ->
    className:  ''
    onUpdate:   ->
    shouldRenderHeader: true
    shouldRenderFooter: true

  getInitialState: ->
    pin: {}
    user: {}
    ready: false


  # Lifecycle Methods
  #
  componentWillMount: ->
    @cursor =
      pin: PinStore.cursor.items.cursor(@props.pin)

  componentDidMount: ->
    @fetch()

  componentDidUpdate: ->
    @props.onUpdate()


  # Fetchers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('pin'), { id: @props.pin }).then =>
      pin   = PinStore.get(@props.pin).toJS()
      user  = UserStore.get(pin.user_id).toJS()
      @setState
        ready:  true
        pin:    pin
        user:   user


  # Renderers
  #
  renderHeader: ->
    return null unless @props.shouldRenderHeader
    <Header pin = { @state.pin.uuid } />

  renderContent: ->
    <section className="content">
      <span className="content">
        { @state.pin.content }
      </span>
      <span> &mdash; </span>
      { @renderUser() }
    </section>

  renderFooter: ->
    return null unless @props.shouldRenderFooter
    <Footer/>

  renderUser: ->
    <a href={ @state.user.url }>
      { @state.user.full_name }
    </a>


  # Main Render
  #
  render: ->
    return null unless @state.ready

    <div className="pin-card cloud-card #{@props.className}" onClick={ @props.onClick }>
      { @renderHeader() }
      { @renderContent() }
      { @renderFooter() }
    </div>
