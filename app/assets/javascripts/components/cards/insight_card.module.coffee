# @cjsx React.DOM

GlobalState = require('global_state/state')

PinStore = require('stores/pin_store')
UserStore = require('stores/user_store.cursor')

Header = require('components/cards/insight/header')
Content = require('components/cards/insight/content')
Origin  = require('components/cards/insight/origin')
StarButton = require('components/cards/insight/star_button')


# Main component
#
InsightCard = React.createClass

  displayName: "InsightCard"
  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  propTypes:
    pin: React.PropTypes.string.isRequired
    scope: React.PropTypes.string.isRequired
    shouldRenderHeader: React.PropTypes.bool
    shouldRenderFooter: React.PropTypes.bool

  statics:
    queries:
      pin: (params = {}) ->
        params          = Object.assign(InsightCard.getDefaultProps(), params)
        headerQuery     = Header.getQuery('pin') if params.shouldRenderHeader
        contentQuery    = Content.getQuery('pin')
        originQuery     = Origin.getQuery('pin') if params.shouldRenderFooter
        starQuery       = StarButton.getQuery('pin')
        pinQuery        = [contentQuery, headerQuery, originQuery, starQuery].filter((part) -> !!part).join(',')
        pinParentQuery  = [contentQuery, originQuery, starQuery].filter((part) -> !!part).join(',')

        """
          Pin {
            id,
            #{pinQuery},
            parent {
              #{pinParentQuery}
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


  # Specifications
  #
  getDefaultProps: ->
    shouldRenderHeader: true
    shouldRenderFooter: true

  getInitialState: ->
    pin:    {}
    ready:  false


  # Lifecycle
  #
  componentDidMount: ->
    @fetch()


  # Helpers
  #


  # Events
  #


  # Renderers
  #
  renderHeader: ->
    return null unless @props.shouldRenderHeader
    <Header pin={ @state.pin.uuid } scope={ @props.scope } />


  renderContent: ->
    insight = @getCursor('insight')

    <section className="content">
      <a href={ insight.get('url') } className="through">
        { insight.get('content') }
      </a>
    </section>


  renderControls: ->
    user = UserStore.get(@getCursor('insight').get('user_id')).toJS()
    <ul className="controls">
      <li className="user">
        <a href={ user.url }>{ user.full_name }</a>
      </li>
      <StarButton pin={ @getCursor('insight').get('id') } />
    </ul>


  renderFooter: ->
    return null unless @props.shouldRenderFooter
    <footer>
      <Origin pin={ @getCursor('insight').get('id') } />
    </footer>
    # <Footer pin={ @state.pin.id } scope={ @props.scope } />


  # Main Render
  #
  render: ->
    return <div className="insight-card cloud-card placeholder" /> unless @state.ready

    className = cx @props.className, cx
      'cloud-card':     true
      'insight-card':   true

    <div className={ className }>
      { @renderContent() }
      { @renderControls() }
      { @renderFooter() }
    </div>

    # <div className={ className }>
    #   { @renderHeader() }
    #   { @renderContent() }
    #   { @renderFooter() }
    # </div>



# Exports
#
module.exports = InsightCard
