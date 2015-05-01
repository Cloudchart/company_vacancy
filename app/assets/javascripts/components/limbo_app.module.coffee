# @cjsx React.DOM

GlobalState      = require('global_state/state')

PinStore         = require('stores/pin_store')

PinsList         = require('components/pinboards/pins')
PinComponent     = require('components/pinboards/pin')

PinForm          = require('components/form/pin_form')
Modal            = require('components/modal_stack')
StandardButton   = require('components/form/buttons').StandardButton


# Utils
#
cx = React.addons.classSet


# Main component
# 
MainComponent = React.createClass

  displayName: 'LimboApp'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      insights: ->
        """
          Viewer {
            limbo_pins {
              #{PinComponent.getQuery('pin')}
            }
          }
        """

  getDefaultProps: ->
    cursor: 
      pins: PinStore.cursor.items

  getInitialState: ->
    isLoaded: false


  # Helpers
  # 
  isLoaded: ->
    @state.isLoaded

  fetch: ->
    GlobalState.fetch(@getQuery('insights'))

  gatherInsights: ->
    @props.cursor.pins
      .filter (pin) =>
        !pin.get('parent_id') && !pin.get('pinnable_id') && 
        !pin.get('pinboard_id') && pin.get('content')
      .valueSeq()
      .sortBy (pin) -> pin.get('created_at')
      .reverse()
      .toArray()


  # Handlers
  # 
  handleCreateButtonClick: ->
    Modal.show(@renderPinForm())


  # Lifecycle Methods
  # 
  componentWillMount: ->
    @fetch().then => @setState isLoaded: true


  # Renderers
  # 
  renderPinForm: ->
    <PinForm
      onDone        = { Modal.hide }
      onCancel      = { Modal.hide } />


  # Main render
  # 
  render: ->
    return null unless @isLoaded()

    <section className="limbo">
      <StandardButton
        className = "cc"
        text      = "Create Insight"
        onClick   = { @handleCreateButtonClick } />
      <PinsList pins = { @gatherInsights() } showPinButton = { false } />
    </section>


# Exports
# 
module.exports = MainComponent
