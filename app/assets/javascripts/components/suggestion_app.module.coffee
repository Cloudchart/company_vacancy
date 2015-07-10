# @cjsx React.DOM

# Imports
# 
GlobalState = require('global_state/state')

UserStore = require('stores/user_store.cursor')
PinboardStore = require('stores/pinboard_store')

UserPinboards = require('components/pinboards/lists/user')
PinboardComponent = require('components/pinboards/pinboard')
PinboardPins = require('components/pinboards/pins/pinboard')
ModalStack = require('components/modal_stack')

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

  # Component Specifications
  # 
  getDefaultProps: ->
    cursor:
      pinboards: PinboardStore.cursor.items
      viewer: UserStore.me()

  getInitialState: ->
    fetchDone: false


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


  # Helpers
  # 
  getPinboards: ->
    PinboardStore
      .filterUserPinboards(@props.cursor.viewer.get('uuid'))
      .sortBy (item) -> item.get('title')
      .valueSeq()
      .toArray()


  # Handlers
  # 
  handlePinboardClick: (uuid, event) ->
    event.preventDefault()

    ModalStack.hide()
    ModalStack.show(@renderSuggestions(uuid))

  handlePinClick: (event) ->
    ModalStack.hide()


  # Renderers
  # 
  renderPinboards: ->
    @getPinboards().map (pinboard) =>
      <section className="cloud-column" key={ pinboard.get('uuid') }>
        <PinboardComponent
          uuid = { pinboard.get('uuid') }
          user_id = { @props.cursor.viewer.get('uuid') }
          onClick = { @handlePinboardClick }
        />
      </section>

  renderSuggestions: (uuid) ->
    component = switch @props.type
      when 'Pinboard'
        <PinboardPins pinboard_id = { uuid } onItemClick = { @handlePinClick } />

    <div className="suggestion-container">
      { component }
    </div>


  # Main render
  # 
  render: ->
    return null unless @state.fetchDone

    <section className="pinboards cloud-columns cloud-columns-flex">
      { @renderPinboards() }
    </section>
