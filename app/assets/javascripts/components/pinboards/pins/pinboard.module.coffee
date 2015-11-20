# @cjsx React.DOM


GlobalState   = require('global_state/state')

PinStore      = require('stores/pin_store')
UserStore     = require('stores/user_store.cursor')
PinboardStore = require('stores/pinboard_store')

PinsList      = require('components/pinboards/pins')
PinComponent  = require('components/pinboards/pin')
Insight       = require('components/cards/insight_card')

ListOfCards   = require('components/cards/list_of_cards')
SeeMore       = require('components/insight/see_more')

SortAttrsMap =
  created_at: 'date created'
  source_content: 'content'


# Exports
#
module.exports = React.createClass

  displayName: 'PinboardPins'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      pins: ->
        """
          Pinboard {
            pins {
              #{Insight.getQuery('pin')}
            },
            edges {
              pins_ids,
              pins_count,
              is_editable
            }
          }
        """

  propTypes:
    pinboard_id: React.PropTypes.string.isRequired


  # Component Specifications
  #
  getDefaultProps: ->
    onItemClick: null

  getInitialState: ->
    isLoaded: false
    sortAttr: 'created_at'


  # Helpers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('pins'), id: @props.pinboard_id)

  isLoaded: ->
    @state.isLoaded

  isApproved: (pin) ->
    return true if      pin.is_approved
    return true unless  pin.is_suggestion
    @cursor.pinboard.get('is_editable')

  getPins: ->
    pins = @cursor.pinboard.get('pins_ids')
      .map (id) -> PinStore.get(id)?.toJS()
      .filter (pin) -> !!pin
      .filter @isApproved

  sortPins: (pins) ->
    sortedPins = pins.sortBy (pin) => pin[@state.sortAttr]
    sortedPins.reverse() if @state.sortAttr == 'created_at'
    sortedPins

  collectPins: ->
    pins = @getPins()
    pins = pins.take(SeeMore.takeSize()) if SeeMore.shouldDisplayComponent(pins.size)
    @sortPins(pins)


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      user:       UserStore.me()
      pins:       PinStore.cursor.items
      pinboard:   PinboardStore.cursor.items.cursor(@props.pinboard_id)

    @fetch().then(=> @setState isLoaded: true) unless @isLoaded()


  # Handlers
  #
  handleSortClick: (event) ->
    event.preventDefault()
    sortAttr = if @state.sortAttr == 'created_at' then 'source_content' else 'created_at'
    @setState sortAttr: sortAttr


  # Renderers
  #
  renderPin: (pin) ->
    <Insight key={ pin.uuid } pin={ pin.uuid } scope='pinboard' />

  renderPins: ->
    @collectPins().map @renderPin

  renderSortInsightsBlock: ->
    return null unless @cursor.user.get('is_editor', false)

    <div className="insights-sort">
      <span>Sorted by: </span>
      <a href="" onClick={ @handleSortClick }>{ SortAttrsMap[@state.sortAttr] }</a>
    </div>


  # Main render
  #
  render: ->
    return null unless @isLoaded()

    <section className="cc-container-common">
      { @renderSortInsightsBlock() }

      <ListOfCards>
        { @renderPins().toArray() }
      </ListOfCards>

      <SeeMore pinsSize = { @getPins().size } type = "collection" />
    </section>
