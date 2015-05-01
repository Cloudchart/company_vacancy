# @cjsx React.DOM

GlobalState      = require('global_state/state')

PinForm          = require('components/form/pin_form')
Modal            = require('components/modal_stack')
StandardButton   = require('components/form/buttons').StandardButton

LimboInsights    = require('components/pinboards/pins/limbo')


# Utils
#
cx = React.addons.classSet


# Main component
# 
MainComponent = React.createClass

  displayName: 'LimboApp'


  # Handlers
  # 
  handleCreateButtonClick: ->
    Modal.show(@renderPinForm())


  # Renderers
  # 
  renderPinForm: ->
    <PinForm
      onDone        = { Modal.hide }
      onCancel      = { Modal.hide } />


  # Main render
  # 
  render: ->
    <section className="limbo">
      <StandardButton
        className = "cc"
        text      = "Create Insight"
        onClick   = { @handleCreateButtonClick } />
      <LimboInsights />
    </section>


# Exports
# 
module.exports = MainComponent
