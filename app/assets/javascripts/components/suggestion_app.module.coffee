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
# cx = React.addons.classSet


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

  getInitialState: ->
    fetchDone: false
    pinboard_id: null
    query: ''


  # Lifecycle Methods
  # 
  componentWillMount: ->
    @fetch().then => @setState fetchDone: true

  # componentDidMount: ->
  # componentWillUnmount: ->


  # Fetchers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('viewer'))

  fetchPins: (pinboard_id) ->
    GlobalState.fetch(@getQuery('pins'), id: pinboard_id)


  # Helpers
  #
  gatherPinboards: ->
    # TODO: don't filter store, use edge
    PinboardStore
      .filterUserPinboards(@props.cursor.viewer.get('uuid'))
      .filter (pinboard) -> pinboard.get('pins_count') > 0
      .sortBy (pinboard) -> pinboard.get('title')
      .valueSeq()
      .toArray()

  gatherPins: ->
    # TODO: don't filter store, use edge
    PinStore
      .filterByPinboardId(@state.pinboard_id)
      .filter (pin) => @filterByContentOrOwner(pin.toJS())
      .sortBy (pin) -> pin.get('created_at')
      .reverse()
      .valueSeq()
      .toArray()

  filterByContentOrOwner: (pin) ->
    return true unless @state.query

    insight = if pin.parent_id then @props.cursor.pins.get(pin.parent_id).toJS() else pin

    insight.content.toLowerCase().indexOf(@state.query.toLowerCase()) != -1 ||
    @props.cursor.users.get(insight.user_id).get('full_name').toLowerCase().indexOf(@state.query.toLowerCase()) != -1


  # Handlers
  # 
  handlePinboardClick: (uuid, event) ->
    event.preventDefault()
    @fetchPins(uuid).then => @setState pinboard_id: uuid

  handlePinClick: (uuid, event) ->
    event.preventDefault()

    attributes =
      parent_id: uuid
      pinboard_id: @props.uuid if @props.type == 'Pinboard'
      pinnable_id: @props.uuid if @props.type != 'Pinboard'
      pinnable_type: @props.type if @props.type != 'Pinboard'
      is_suggestion: true

    PinStore.create(attributes).then(ModalStack.hide, ModalStack.hide)

  handleBackButtonClick: (event) ->
    @setState pinboard_id: null

  handleQueryChange: (event) ->
    @setState query: event.target.value


  # Renderers
  # 
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
    return null unless @state.fetchDone

    if @state.pinboard_id
      <section className="pins cloud-columns cloud-columns-flex">
        <button className="transparent" onClick={ @handleBackButtonClick }>
          <i className="fa fa-angle-left" />
        </button>
        <CloseModalButton />

        <header>
          <input
            autoFocus =  { true }
            value =  { @state.query }
            onChange =  { @handleQueryChange }
            placeholder = 'Search by content or author'
          />
        </header>

        { @renderPins() }
      </section>
    else
      <section className="pinboards cloud-columns cloud-columns-flex">
        <CloseModalButton />
        { @renderPinboards() }
      </section>
