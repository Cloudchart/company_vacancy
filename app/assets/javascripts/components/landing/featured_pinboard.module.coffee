# @cjsx React.DOM

GlobalState     = require('global_state/state')

PinboardStore   = require('stores/pinboard_store')
PinStore        = require('stores/pin_store')

FollowButton    = require('components/pinboards/follow_button')
InsightPreview  = require('components/pinboards/pin')

StacksCount               = 3
MaxInsightContentLength   = 200


# Exports
#
module.exports = React.createClass

  displayName: 'FeaturedPinboard'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:
    queries:
      pinboard: -> # TODO: Rewrite Insight
        """
          Pinboard {
            #{FollowButton.getQuery('pinboard')},

            pins {
              #{InsightPreview.getQuery('pin')}
            },

            edges {
              pins_ids
            }
          }
        """

  fetch: ->
    GlobalState.fetch(@getQuery('pinboard'), { id: @props.pinboard }).done =>
      @setState
        ready: true


  switchInsight: ->
    stackIndex    = parseInt(Math.random() * 10 % StacksCount)
    stackRef      = @refs['stack-' + stackIndex]
    return unless stackRef
    stackNode     = stackRef.getDOMNode()
    insightIndex  = parseInt(Math.random() * 10 % stackNode.childNodes.length) || 0

    @setState
      opacityIndices: @state.opacityIndices.set(stackIndex, insightIndex)


  recalculateHeight: ->
    return if @__heights_calculated

    Immutable.Seq(@refs).forEach (ref, key) ->
      return unless node = ref.getDOMNode()

      maxHeight = Immutable.Seq(node.childNodes)
        .map (child) -> $(child.childNodes[0]).outerHeight(true)
        .maxBy (value) -> value
      node.style.height = maxHeight + 'px'

      @__heights_calculated = true



  # Lifecycle
  #
  componentWillMount: ->
    @cursor =
      pinboard: PinboardStore.cursor.items.cursor(@props.pinboard)

    @fetch()


  componentDidMount: ->
    @recalculateHeight()
    @switchInsightInterval = setInterval @switchInsight, 5 * 1000


  componentWillUnmount: ->
    clearInterval @switchInsightInterval


  componentDidUpdate: ->
    @recalculateHeight()


  getInitialState: ->
    opacityIndices: Immutable.List()
    ready:          false


  # Renders
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

    <div key={ id } className="item" style={ opacity: opacity }>
      <InsightPreview uuid={ id } skipRenderComment={ true } />
    </div>


  renderStack: (items, i) ->
    <div className="item" key={ i }>
      <div className="stack" ref={ 'stack-' + i }>
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


  # Main Render
  #
  render: ->
    return null unless @state.ready

    <section className="cc-container-common producthunt">
      { @renderHeader() }

      <section className="full-width">
        <section className="content columns">
          { @renderStacks() }
        </section>
      </section>
    </section>
