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

  displayName: 'CompanyTabs'

  propTypes:
    onChange: React.PropTypes.func.isRequired
    canEdit: React.PropTypes.bool.isRequired


  # Helpers
  # 
  getVisibleTabs: ->
    Immutable.OrderedMap(
      timeline:  !Timeline.isEmpty() || @props.canEdit
      about:     true
      users:     @props.canEdit
      settings:  @props.canEdit
    ).filter (visible) -> visible
     .keySeq()

  getCurrentTab: ->
    tabName = location.hash.substr(1) || null
    return 'timeline' if tabName and tabName.match(/^#story/)
    tabName


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
