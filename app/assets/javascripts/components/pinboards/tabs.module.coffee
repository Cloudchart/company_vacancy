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
    onChange: React.PropTypes.func.isRequired


  # Helpers
  # 
  getVisibleTabs: ->
    Immutable.OrderedMap(
      insights:  true
      settings:  true
    ).filter (visible) -> visible
     .keySeq()


  # Main render
  # 
  render: ->
    <Tabs
      getCurrentTab  = { @getCurrentTab }
      onChange       = { @props.onChange }
      tabs           = { @getVisibleTabs() } />


# Exports
# 
module.exports = MainComponent
