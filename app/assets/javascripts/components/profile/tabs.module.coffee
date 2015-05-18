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

  displayName: 'ProfileTabs'

  propTypes:
    companiesNumber: React.PropTypes.number
    insightsNumber:  React.PropTypes.number
    onChange:        React.PropTypes.func.isRequired
    canEdit:         React.PropTypes.bool.isRequired


  # Helpers
  # 
  getVisibleTabs: ->
    Immutable.OrderedMap(
      insights:  true
      feed:      true
      companies: true
      settings:  @props.canEdit
    ).filter (visible) -> visible
    .keySeq()

  getCurrentTab: ->
    tabName = location.hash.substr(1) || null
    return 'timeline' if tabName and tabName.match(/^#story/)
    tabName


  # Renderers
  #
  renderInsightsNumber: ->
    return null unless (insightsCount = @props.insightsNumber) > 0

    <strong>{ insightsCount }</strong>

  renderCompaniesNumber: ->
    return null unless (companiesCount = @props.companiesNumber) > 0

    <strong>{ companiesCount }</strong>

  renderTabName: (key) ->
    switch key
      when 'insights'
        <span>Insights { @renderInsightsNumber() }</span>
      when 'companies'
        <span>Companies { @renderCompaniesNumber() }</span>
      when 'feed'
        "Feed"
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
