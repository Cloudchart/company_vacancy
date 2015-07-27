# @cjsx React.DOM

GlobalState = require('global_state/state')

PinStore = require('stores/pin_store')

Header = require('components/cards/insight/header')
Content = require('components/cards/insight/content')
Footer = require('components/cards/insight/footer')


# Main component
#
module.exports = React.createClass

  displayName: "InsightCard"

  propTypes:
    pin: React.PropTypes.string.isRequired

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:
    queries:
      pin: ->
        """
          Pin {
            #{Header.getQuery('pin')},
            #{Content.getQuery('pin')},
            #{Footer.getQuery('pin')},
            parent {
              #{Header.getQuery('pin')},
              #{Content.getQuery('pin')},
              #{Footer.getQuery('pin')}
            }
          }
        """


  # Component Specifications
  #
  getDefaultProps: ->
    shouldRenderHeader: true
    shouldRenderFooter: true

  getInitialState: ->
    pin: {}
    ready: false


  # Lifecycle Methods
  #
  # componentWillMount: ->

  componentDidMount: ->
    @fetch()


  # Fetchers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('pin'), { id: @props.pin }).then =>
      @setState
        ready: true
        pin: PinStore.get(@props.pin).toJS()


  # Renderers
  #
  renderHeader: ->
    return null unless @props.shouldRenderHeader
    <Header pin = { @state.pin.uuid } />

  renderContent: ->
    <Content pin = { @state.pin.parent_id || @state.pin.uuid } />

  renderFooter: ->
    return null unless @props.shouldRenderFooter
    <Footer pin = { @state.pin.uuid } />

  renderUser: ->
    <a href={ @state.user.url }>
      { @state.user.full_name }
    </a>


  # Main Render
  #
  render: ->
    return null unless @state.ready

    <div className="pin-card cloud-card">
      { @renderHeader() }
      { @renderContent() }
      { @renderFooter() }
    </div>
