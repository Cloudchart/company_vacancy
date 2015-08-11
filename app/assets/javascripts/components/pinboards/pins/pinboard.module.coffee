# @cjsx React.DOM


GlobalState   = require('global_state/state')

PinStore      = require('stores/pin_store')
UserStore     = require('stores/user_store.cursor')
PinboardStore = require('stores/pinboard_store')

PinsList      = require('components/pinboards/pins')
PinComponent  = require('components/pinboards/pin')
Insight       = require('components/cards/insight_card')

ListOfCards   = require('components/cards/list_of_cards')

constants = require('constants')


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


  # Helpers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('pins'), id: @props.pinboard_id)

  isLoaded: ->
    @state.isLoaded

  shouldLimitPins: (pins=@getPins()) ->
    pins.size >= 12 && !@cursor.user.get('is_authenticated')

  isApproved: (pin) ->
    return true if      pin.is_approved
    return true unless  pin.is_suggestion
    @cursor.pinboard.get('is_editable')

  getPins: ->
    pins = @cursor.pinboard.get('pins_ids')
      .map (id) -> PinStore.get(id)?.toJS()
      .filter (pin) -> !!pin
      .filter @isApproved

  collectPins: ->
    pins = @getPins()
    pins = pins.take(6) if @shouldLimitPins(pins)
    pins
      .sortBy (pin) -> pin.created_at
      .reverse()


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
  handleSignInClick: (event) ->
    location.href = constants.TWITTER_AUTH_PATH


  # Renderers
  #
  renderSeeMore: ->
    return null unless @shouldLimitPins()
    text =
      """
        There are <strong>#{@cursor.pinboard.get('pins_count')} other valuable insights</strong> in this collection.
        Sign up to get access to dozens of other insights and regular updates,
        follow the collection, save insights and suggest your own.
      """

    <section className="see-more">
      <p dangerouslySetInnerHTML={ __html: text }></p>
      <button className="cc" onClick={@handleSignInClick}>{ "Sign in with Twitter" }</button>
    </section>

  renderPin: (pin) ->
    <Insight key={ pin.uuid } pin={ pin.uuid } scope='pinboard' />

  renderPins: ->
    @collectPins().map @renderPin


  # Main render
  #
  render: ->
    return null unless @isLoaded()

    <section className="cc-container-common">
      <ListOfCards>
        { @renderPins().toArray() }
      </ListOfCards>
      { @renderSeeMore() }
    </section>
