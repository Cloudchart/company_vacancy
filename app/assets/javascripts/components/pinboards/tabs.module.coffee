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
    canEdit:         React.PropTypes.bool
    onChange:        React.PropTypes.func.isRequired

  getDefaultProps: ->
    insightsNumber: null
    canEdit:        false


  # Helpers
  #
  getVisibleTabs: ->
    Immutable.OrderedMap(
      insights:  true
      users:     @props.canEdit
      settings:  @props.canEdit
    ).filter (visible) -> visible
     .keySeq()


  # Renderers
  #
  renderInsightsNumber: ->
    return null unless (insightsCount = @props.insightsNumber) > 0

    <strong>{ insightsCount }</strong>

  renderTabName: (key, options = {}) ->
    switch key
      when 'insights'
        if options.plain then "Insights" else <span>Insights { @renderInsightsNumber() }</span>
      when 'users'
        if options.plain then "Users" else <span>Users</span>
      when 'settings'
        if options.plain then "Settings" else <span>Settings</span>


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
