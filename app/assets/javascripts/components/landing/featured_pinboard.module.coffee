# @cjsx React.DOM

GlobalState     = require('global_state/state')

PinboardStore   = require('stores/pinboard_store')
PinStore        = require('stores/pin_store')
FeatureStore    = require('stores/feature_store')

FollowButton    = require('components/pinboards/follow_button')
InsightCard     = require('components/cards/insight_card')
device          = require('utils/device')

cx = React.addons.classSet

StacksCount               = if device.is_iphone then 1 else 3
MaxInsightContentLength   = 200


# Exports
#
module.exports = React.createClass

  displayName: 'FeaturedPinboard'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  propTypes:
    scope:  React.PropTypes.string.isRequired

  statics:
    queries:
      pinboard: -> # TODO: Rewrite Insight
        """
          Pinboard {
            #{FollowButton.getQuery('pinboard')},
            pins {
              #{InsightCard.getQuery('pin')}
            },
            features,
            edges {
              pins_ids,
              assigned_image_url,
              assigned_image_display_types,
              features
            }
          }
        """

  fetch: ->
    GlobalState.fetch(@getQuery('pinboard'), { id: @props.pinboard }).done (json) =>
      @setState
        ready: true


  switchInsight: ->
    stackIndex    = parseInt(Math.random() * 10 % StacksCount)
    return if stackIndex == @state.hoverStackIndex

    stackRef      = @refs['stack-' + stackIndex]
    return unless stackRef

    stackNode     = stackRef.getDOMNode()
    insightIndex  = parseInt(Math.random() * 10 % stackNode.childNodes.length) || 0

    @setState
      opacityIndices: @state.opacityIndices.set(stackIndex, insightIndex)


  observeMutation: ->
    clearTimeout @mutationTimeout
    @mutationTimeout = setTimeout @recalculateHeight, 250


  recalculateHeight: ->
    return if @__heights_calculated

    Immutable.Seq(@refs).forEach (ref, key) ->
      return unless node = ref.getDOMNode()

      maxHeight = Immutable.Seq(node.childNodes)
        .map (child) -> $(child.childNodes[0]).outerHeight(true)
        .maxBy (value) -> value
      node.style.height = maxHeight + 'px'

      @__heights_calculated = true


  handleStackMouseEnter: (index, e) ->
    @setState
      hoverStackIndex: index


  handleStackMouseLeave: (index, e) ->
    @setState
      hoverStackIndex: null



  # Lifecycle
  #
  componentWillMount: ->
    @cursor =
      pinboard: PinboardStore.cursor.items.cursor(@props.pinboard)

    @fetch()


  componentDidMount: ->
    @switchInsightInterval = setInterval @switchInsight, 8 * 1000


  componentWillUnmount: ->
    clearInterval @switchInsightInterval
    @mutationObserver.disconnect()


  componentDidUpdate: (prevProps, prevState) ->
    return if device.is_iphone
    # @recalculateHeight()
    if @state.ready && !@mutation_observer
      @mutationObserver = new MutationObserver(@observeMutation)
      @mutationObserver.observe(@getDOMNode(), { childList: true, subtree: true })


  getInitialState: ->
    opacityIndices: Immutable.List()
    ready:          false


  # Helpers
  #
  getStyleForBgImage: ->
    feature = @cursor.pinboard.get('features').find (item) => item.get('scope') == @props.scope
    return unless feature
    feature = FeatureStore.get(feature.get('id')).toJS()
    background: "url(#{feature.assigned_image_url}) no-repeat center center"
    backgroundSize: 'cover'


  getClassesForBgimage: ->
    feature = @cursor.pinboard.get('features').find (item) => item.get('scope') == @props.scope
    return cx({}) unless feature
    feature = FeatureStore.get(feature.get('id')).toJS()

    cx
      'bg-image':   true
      blurred:      feature.display_types.indexOf('blurred') >= 0
      darkened:     feature.display_types.indexOf('darkened') >= 0


  # Renderers
  #
  renderHeader: ->
    return null unless @cursor.pinboard.deref(false)

    <header className="padded">
      <h1>
        <a href={ @cursor.pinboard.get('url') } className="see-through">
          { @cursor.pinboard.get('title') } &mdash;
        </a>
      </h1>
      <FollowButton pinboard={ @props.pinboard } />
    </header>


  renderInsight: (stackIndex, insight, i) ->
    id        = insight.get('uuid')
    opacity   = if (@state.opacityIndices.get(stackIndex) || 0) == i then 1 else 0

    <div key={ id } className="item" style={ opacity: opacity, pointerEvents: if opacity == 1 then 'auto' else 'none' }>
      <InsightCard pin={ id } scope='pinboard' shouldRenderHeader=false />
    </div>


  renderStack: (items, i) ->
    <div className="item" key={ i }>
      <div className="stack" ref={ 'stack-' + i } onMouseEnter={ @handleStackMouseEnter.bind(@, i) } onMouseLeave={ @handleStackMouseLeave.bind(@, i) }>
        {
          items
            .map @renderInsight.bind(@, i)
            .toArray()
        }
      </div>
    </div>


  renderStacks: ->
    return null if @cursor.pinboard.get('pins_ids', Immutable.Seq()).size == 0

    @cursor.pinboard.get('pins_ids')
      .map      (id)      -> PinStore.get(id)
      .sortBy   (pin)     -> pin.get('created_at')
      .filter   (pin)     ->
        insight = if parent_id = pin.get('parent_id') then PinStore.get(parent_id) else pin
        content = insight.get('content') || ''
        content.length < MaxInsightContentLength
      .groupBy  (pin, i)  -> i % StacksCount
      .map      @renderStack
      .toArray()


  # Main render
  #
  render: ->
    return null unless @state.ready
    return null if device.is_iphone

    <section className="cc-container-common featured-pinboard full-width">
      { @renderHeader() }

      <section className="full-width">
        <div className = { @getClassesForBgimage() } style = { @getStyleForBgImage() } />

        <section className="content columns">
          { @renderStacks() }
        </section>
      </section>
    </section>
