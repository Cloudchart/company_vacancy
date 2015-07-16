# @cjsx React.DOM

# Imports
# 
GlobalState = require('global_state/state')

UserStore = require('stores/user_store.cursor')
PinboardStore = require('stores/pinboard_store')
PinStore = require('stores/pin_store')

UserPinboards = require('components/pinboards/lists/user')
PinboardComponent = require('components/pinboards/pinboard')
PinComponent = require('components/pinboards/pin')
ModalStack = require('components/modal_stack')
CloseModalButton = require('components/form/buttons').CloseModalButton

# Utils
#
cx = React.addons.classSet


# Main component
# 
module.exports = React.createClass

  displayName: 'SuggestionApp'
  
  propTypes:
    uuid: React.PropTypes.string.isRequired
    type: React.PropTypes.string.isRequired
  
  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:
    queries:
      viewer: ->
        """
          Viewer {
            edges {
              related_pinboards
            }
          }
        """

      pinboards: ->
        """
          Viewer {
            #{UserPinboards.getQuery('pinboards')}
          }
        """

      pins: ->
        """
          Pinboard {
            pins {
              #{PinComponent.getQuery('pin')}
            }
          }
        """


  # Component Specifications
  # 
  getDefaultProps: ->
    cursor:
      viewer: UserStore.me()
      users: UserStore.cursor.items
      pins: PinStore.cursor.items
      pinboards: PinboardStore.cursor.items

  getInitialState: ->
    fetched: false
    pinboard_id: null
    query: ''
    fetchingPins: false


  # Lifecycle Methods
  # 
  componentWillMount: ->
    @fetch()

  # componentDidMount: ->
  # componentWillUnmount: ->


  # Fetchers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('viewer')).then @fetchPinboards

  fetchPinboards: ->
    GlobalState.fetch(@getQuery('pinboards')).then => @setState fetched: true

  fetchPins: (pinboard_id) ->
    GlobalState.fetch(@getQuery('pins'), id: pinboard_id)


  # Helpers
  #
  pinboardsIds: ->
    @props.cursor.viewer.get('related_pinboards', Immutable.Seq())
      .filter @finterByCurrentPinboardAndPinsCount
      .map (i) -> i.get('uuid')
      .valueSeq()

  gatherPinboards: ->
    @props.cursor.viewer.get('related_pinboards')
      .map (pinboard) => @props.cursor.pinboards.get(pinboard.get('uuid'))
      .filter @finterByCurrentPinboardAndPinsCount
      .sortBy (pinboard) -> pinboard.get('title')
      .valueSeq()
      .toArray()

  gatherPins: ->
    # TODO: don't filter store, use edge
    PinStore
      .filterByPinboardId(@state.pinboard_id)
      .filter @filterByContentOrOwner
      .sortBy (pin) -> pin.get('created_at')
      .reverse()
      .valueSeq()
      .toArray()

  filterByContentOrOwner: (pin) ->
    return true unless @state.query

    insight = if pin.get('parent_id') then @props.cursor.pins.get(pin.get('parent_id')) else pin

    insight.get('content').toLowerCase().indexOf(@state.query.toLowerCase()) != -1 ||
    @props.cursor.users.get(insight.get('user_id')).get('full_name').toLowerCase().indexOf(@state.query.toLowerCase()) != -1

  finterByCurrentPinboardAndPinsCount: (pinboard) ->
    pinboard.get('uuid') != @props.uuid && pinboard.get('pins_count') > 0

  # Handlers
  # 
  handlePinboardClick: (uuid, event) ->
    event.preventDefault()
    @setState fetchingPins: true

    @fetchPins(uuid).then =>
      @setState
        pinboard_id: uuid
        fetchingPins: false
        query: ''

  handlePinClick: (uuid, event) ->
    event.preventDefault()

    insight_id = @props.cursor.pins.cursor(uuid).get('parent_id') || uuid

    attributes =
      parent_id: insight_id
      pinboard_id: @props.uuid if @props.type == 'Pinboard'
      pinnable_id: @props.uuid if @props.type != 'Pinboard'
      pinnable_type: @props.type if @props.type != 'Pinboard'
      is_suggestion: true

    existing_suggestion = @props.cursor.pins
      .filter (pin) -> pin.get('is_suggestion') && pin.get('parent_id') == attributes.parent_id && pin.get('pinboard_id') == attributes.pinboard_id
      .first()

    if existing_suggestion
      ModalStack.hide()
    else
      PinStore.create(attributes).then(ModalStack.hide, ModalStack.hide)

  handleBackButtonClick: (event) ->
    @setState pinboard_id: null

  handleQueryChange: (event) ->
    @setState query: event.target.value


  # Renderers
  #
  renderPlaceholders: (type) ->
    container_classes = cx
      pinboards: type == 'pinboard'
      pins: type == 'pin'
      'cloud-columns': true
      'cloud-columns-flex': true

    item_classes = cx
      pinboard: type == 'pinboard'
      pin: type == 'pin'
      'cloud-card': true
      'placeholder': true

    # TODO: speed up related pinboards request
    # placeholders = Immutable.Repeat('dummy', @pinboardsIds().size || 2).map (_, i) ->
    placeholders = Immutable.Repeat('dummy', 2).map (_, i) ->
      <section key={ i } className="cloud-column">
        <section className={ item_classes } />
      </section>

    <section className={ container_classes }>
      <CloseModalButton />
      { placeholders.toArray() }
    </section>

  renderPinboards: ->
    @gatherPinboards().map (pinboard) =>
      <section className="cloud-column" key={ pinboard.get('uuid') }>
        <PinboardComponent
          uuid = { pinboard.get('uuid') }
          user_id = { @props.cursor.viewer.get('uuid') }
          onClick = { @handlePinboardClick }
        />
      </section>

  renderPins: ->
    @gatherPins().map (pin) =>
      <section className="cloud-column" key={ pin.get('uuid') }>
        <PinComponent
          uuid = { pin.get('uuid') }
          onClick = { @handlePinClick }
        />
      </section>


  # Main render
  # 
  render: ->
    return @renderPlaceholders('pinboard') unless @state.fetched
    return @renderPlaceholders('pin') if @state.fetchingPins
    return <div>Your collections are empty</div> if @props.cursor.viewer.get('related_pinboards').size == 0

    if @state.pinboard_id
      <section className="pins cloud-columns cloud-columns-flex">
        <button className="back transparent" onClick={ @handleBackButtonClick }>
          <i className="fa fa-angle-left" />
        </button>
        <CloseModalButton />

        <header>
          <input
            autoFocus = true
            value = { @state.query }
            onChange = { @handleQueryChange }
            placeholder = "Search by content or author"
          />
        </header>

        { @renderPins() }
      </section>
    else
      <section className="pinboards cloud-columns cloud-columns-flex">
        <CloseModalButton />
        { @renderPinboards() }
      </section>
