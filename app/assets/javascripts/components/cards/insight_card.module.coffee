# @cjsx React.DOM

GlobalState = require('global_state/state')

PinStore    = require('stores/pin_store')

Header      = require('components/cards/insight/header')
Content     = require('components/cards/insight/content')
Footer      = require('components/cards/insight/footer')


# Main component
#
InsightCard = React.createClass

  displayName: "InsightCard"


  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  propTypes:
    pin:  React.PropTypes.string.isRequired


  getDefaultProps: ->
    shouldRenderHeader: true
    shouldRenderFooter: true


  getInitialState: ->
    pin:    {}
    ready:  false


  statics:
    queries:
      pin: (params = {}) ->
        params    = Object.assign(InsightCard.getDefaultProps(), params)

        headerQuery   = Header.getQuery('pin') if params.shouldRenderHeader
        contentQuery  = Content.getQuery('pin')
        footerQuery   = Footer.getQuery('pin') if params.shouldRenderFooter
        pinQuery      = [headerQuery, contentQuery, footerQuery].filter((part) -> !!part).join(',')

        """
          Pin {
            id,
            #{pinQuery},
            parent {
              #{contentQuery}
            }
          }
        """

  fetch: ->
    GlobalState.fetch(@getQuery('pin', @props), { id: @props.pin }).then =>
      @setState
        ready: true
        pin: PinStore.get(@props.pin).toJS()


  # Helpers
  #


  # Events
  #


  # Lifecycle
  #

  componentDidMount: ->
    @fetch()


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


  # Main Render
  #
  render: ->
    return null unless @state.ready

    <div className="insight-card cloud-card">
      { @renderHeader() }
      { @renderContent() }
      { @renderFooter() }
    </div>


# Exports
#
module.exports = InsightCard
