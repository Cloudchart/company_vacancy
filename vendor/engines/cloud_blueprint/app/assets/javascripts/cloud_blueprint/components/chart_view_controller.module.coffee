# Imports
#
tag = React.DOM

ChartAppSettingsStore   = require('cloud_blueprint/stores/chart_app_settings_store')

Chart                   = require('cloud_blueprint/components/chart')
IdentityBox             = require('cloud_blueprint/components/identity_box')
IdentityBoxToggleButton = require('cloud_blueprint/components/identity_box_toggle_button')


# Functions
#
getStateFromStores = (key) ->
  state           = {}
  state.settings  = ChartAppSettingsStore.get()
  state


# Main Component
#
Component = React.createClass


  refreshStateFromStores: ->
    @setState(getStateFromStores(@props.key))


  componentDidMount: ->
    ChartAppSettingsStore.on('change', @refreshStateFromStores)
    # ChartStore.on('change', @refreshStateFromStores)
    # PersonStore.on('change', @refreshStateFromStores)
    # VacancyStore.on('change', @refreshStateFromStores)
    # NodeStore.on('change', @refreshStateFromStores)
    # NodeIdentityStore.on('change', @refreshStateFromStores)
  
  
  componentWillUnmount: ->
    ChartAppSettingsStore.off('change', @refreshStateFromStores)
    # ChartStore.off('change', @refreshStateFromStores)
    # PersonStore.off('change', @refreshStateFromStores)
    # VacancyStore.off('change', @refreshStateFromStores)
    # NodeStore.off('change', @refreshStateFromStores)
    # NodeIdentityStore.off('change', @refreshStateFromStores)
  
  
  getDefaultProps: ->
    props = {}
    props


  getInitialState: ->
    state = getStateFromStores(@props.key)
    state


  render: ->
    (tag.div {
      style:
        display:  '-webkit-flex'
        position: 'absolute'
        left:     0
        top:      0
        right:    0
        bottom:   0
    },
      # IdentityBoxToggleButton
      #
      (IdentityBoxToggleButton @state)

      # IdentityBox
      #
      (IdentityBox @state)
      
      # Chart
      #
      (Chart @state)
    )


# Exports
#
module.exports = Component
