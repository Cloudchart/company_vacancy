# @cjsx React.DOM

GlobalState = require('global_state/state')

PinStore    = require('stores/pin_store')

Header      = require('components/cards/insight/header')
Reflection  = require('components/cards/insight/reflection')
Content     = require('components/cards/insight/content')
Footer      = require('components/cards/insight/footer')


# Main component
#
InsightCard = React.createClass

  displayName: "InsightCard"


  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  propTypes:
    pin:    React.PropTypes.string.isRequired
    scope:  React.PropTypes.string.isRequired


  getDefaultProps: ->
    shouldRenderHeader: true
    shouldRenderFooter: true


  getInitialState: ->
    pin:    {}
    ready:  false


  statics:
    queries:
      pin: (params = {}) ->
        params          = Object.assign(InsightCard.getDefaultProps(), params)
        headerQuery     = Header.getQuery('pin') if params.shouldRenderHeader
        contentQuery    = Content.getQuery('pin')
        footerQuery     = Footer.getQuery('pin') if params.shouldRenderFooter
        pinQuery        = [contentQuery, headerQuery, footerQuery].filter((part) -> !!part).join(',')
        pinParentQuery  = [contentQuery, footerQuery].filter((part) -> !!part).join(',')

        """
          Pin {
            id,
            #{pinQuery},
            edges {
              should_show_reflection
            },
            parent {
              #{pinParentQuery},
              edges {
                should_show_reflection
              }
            }
          }
        """

  fetch: ->
    GlobalState.fetch(@getQuery('pin', @props), { id: @props.pin }).then =>
      pin         = PinStore.get(@props.pin).toJS()
      parent_pin  = PinStore.get(pin.parent_id).toJS() if pin.parent_id

      @addCursor 'insight', PinStore.cursor.items.cursor((parent_pin || pin).id)

      @setState
        ready: true
        pin:      pin
        insight:  parent_pin || pin


  # Helpers
  #
  shouldShowReflection: ->
    @getCursor('insight').get('should_show_reflection')

  shouldRenderHeader: ->
    @props.shouldRenderHeader and !@shouldShowReflection()


  # Events
  #


  # Lifecycle
  #
  componentDidMount: ->
    @fetch()


  componentDidUpdate: ->
    @props.onUpdate() if typeof @props.onUpdate is 'function'


  # Renderers
  #
  renderHeader: ->
    return null unless @shouldRenderHeader()
    <Header pin={ @state.pin.uuid } scope={ @props.scope } />

  renderReflection: ->
    return null unless @shouldShowReflection()
    <Reflection insight={ @state.insight.id } />

  renderContent: ->
    <Content pin = { @state.pin.parent_id || @state.pin.uuid } url = { @state.pin.url } />

  renderFooter: ->
    return null unless @props.shouldRenderFooter
    <Footer pin={ @state.pin.id } scope={ @props.scope } />


  # Main Render
  #
  render: ->
    if @state.ready

      className = cx @props.className, cx
        'cloud-card':     true
        'insight-card':   true

      <div className={ className }>
        { @renderHeader() }
        { @renderReflection() }
        { @renderContent() }
        { @renderFooter() }
      </div>
    else
      <div className="insight-card cloud-card placeholder" />


# Exports
#
module.exports = InsightCard
