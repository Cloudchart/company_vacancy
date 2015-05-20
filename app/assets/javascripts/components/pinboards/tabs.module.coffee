# @cjsx React.DOM

# Imports
# 
Timeline = require('components/company/timeline')
Tabs     = require('components/shared/tabs')


# Utils
#
cx = React.addons.classSet


# Main component
# 
MainComponent = React.createClass

  displayName: 'PinboardTabs'

  propTypes:
    insightsNumber:  React.PropTypes.number
    onChange:        React.PropTypes.func.isRequired


  # Helpers
  # 
  getVisibleTabs: ->
    Immutable.OrderedMap(
      insights:  true
      settings:  true
    ).filter (visible) -> visible
     .keySeq()


  # Renderers
  #
  renderInsightsNumber: ->
    return null unless (insightsCount = @props.insightsNumber) > 0

    <strong>{ insightsCount }</strong>

  renderTabName: (key) ->
    switch key
      when 'insights'
        <span>Insights { @renderInsightsNumber() }</span>
      when 'settings'
        "Settings"


  # Main render
  # 
  render: ->
    <Tabs
      getCurrentTab  = { @getCurrentTab }
      renderTabName  = { @renderTabName }
      onChange       = { @props.onChange }
      tabs           = { @getVisibleTabs() } />


# Exports
# 
module.exports = MainComponent
