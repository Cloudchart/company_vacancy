# @cjsx React.DOM

GlobalState = require('global_state/state')


PinboardCard      = require('components/cards/pinboard_card')
InsightCard       = require('components/cards/insight_card')
ListOfCards       = require('components/cards/list_of_cards')
FeaturedPinboard  = require('components/landing/featured_pinboard')

PinStore      = require('stores/pin_store')
PinboardStore = require('stores/pinboard_store')


# Exports
#
module.exports = React.createClass

  displayName: 'DailyFeed'

  mixins: [GlobalState.query.mixin]

  propTypes:
    date:     React.PropTypes.instanceOf(Date).isRequired
    onDone:   React.PropTypes.func.isRequired


  getInitialState: ->
    ready:                false
    date:                 moment(@props.date)
    feed_pins_ids:        []
    feed_pinboards_ids:   []


  statics:
    queries:
      viewer: ->
        """
          Viewer {
            feed_pins {
              #{InsightCard.getQuery('pin')}
            },
            feed_pinboards {
              #{PinboardCard.getQuery('pinboard')}
            },
            feed_featured_pinboards {
              #{FeaturedPinboard.getQuery('pinboard')}
            }
          }
        """

  fetch: ->
    GlobalState.fetch(@getQuery('viewer'), { force: true, params: { date: @state.date.format('LL') } }).then (json) =>
      { feed_pins, feed_pinboards, feed_featured_pinboards } = json.query

      @setState
        feed_featured_pinboard_id:  if feed_featured_pinboards then feed_featured_pinboards.ids[0] else null
        feed_pinboards_ids:         if feed_pinboards then feed_pinboards.ids else []
        feed_pins_ids:              if feed_pins then feed_pins.ids else []
        ready:                      true

      @props.onDone()


  # Lifecycle
  #

  componentWillMount: ->
    @fetch()


  shouldComponentUpdate: ->
    !@state.ready


  # Render Header
  #
  renderHeader: ->
    <header>
      <h1><strong>{ @state.date.format('LL') }</strong></h1>
    </header>


  # Render Feed Items
  #

  renderFeedItem: (record) ->
    switch record.type
      when 'Pin'
        <InsightCard key={ record.id } pin={ record.id } scope='feed' />
      when 'Pinboard'
        <PinboardCard key={ record.id } pinboard={ record.id } />


  renderFeedItems: ->
    pins = @state.feed_pins_ids.map (id) -> Object.assign PinStore.get(id).toJS(), type: 'Pin'
    pinboards = @state.feed_pinboards_ids.map (id) -> Object.assign PinboardStore.get(id).toJS(), type: 'Pinboard'

    items = [].concat(pins).concat(pinboards)

    renderedItems = Immutable.Seq(items)
      .sortBy (record) -> record.created_at
      .reverse()
      .map @renderFeedItem

    return null if renderedItems.size == 0

    <section className="cc-container-common glued">
      <ListOfCards>
        { renderedItems.toArray() }
      </ListOfCards>
    </section>


  renderFeaturedPinboard: ->
    return null unless @state.feed_featured_pinboard_id
    <FeaturedPinboard pinboard={ @state.feed_featured_pinboard_id } scope='feed' />

  # Render
  #
  render: ->
    return null unless @state.ready

    <section className="cc-container-common">
      <section className="cc-container-common">
        { @renderHeader() }
      </section>
      { @renderFeedItems() }
      { @renderFeaturedPinboard() }
    </section>
