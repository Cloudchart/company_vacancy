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

  getInitialState: ->
    fetchDone: false
    pinboard_id: null


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
    PinboardStore
      .filterUserPinboards(@props.cursor.viewer.get('uuid'))
      .filter (item) -> item.get('pins_count') > 0
      .sortBy (item) -> item.get('title')
      .valueSeq()
      .toArray()

  gatherPins: ->
    PinStore.filterByPinboardId(@state.pinboard_id)
      .valueSeq()
      .sortBy (pin) -> pin.get('created_at')
      .reverse()
      .toArray()


  # Handlers
  # 
  handlePinboardClick: (uuid, event) ->
    event.preventDefault()
    @fetchPins(uuid).then => @setState pinboard_id: uuid

  handlePinClick: (pin, event) ->
    event.preventDefault()
    ModalStack.hide()

  handleBackButtonClick: (event) ->
    @setState pinboard_id: null


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
        { @renderPins() }
      </section>
    else
      <section className="pinboards cloud-columns cloud-columns-flex">
        <CloseModalButton />
        { @renderPinboards() }
      </section>
