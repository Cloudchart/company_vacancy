# @cjsx React.DOM

# Imports
#
Dropdown = require('components/form/dropdown')


# Utils
#
cx = React.addons.classSet


# Main component
# 
MainComponent = React.createClass

  displayName: 'Tabs'

  propTypes:
    getCurrentTab: React.PropTypes.func
    renderTabName: React.PropTypes.func
    onChange:      React.PropTypes.func.isRequired
    tabs:          React.PropTypes.instanceOf(Immutable.Seq).isRequired

  getDefaultProps: ->
    getCurrentTab: -> null
    renderTabName: (tabName) -> tabName

  getInitialState: ->
    currentTab: @getInitialTab()

  
  # Lifecycle Methods
  # 
  componentDidMount: ->
    window.addEventListener 'hashchange', @handleHashChange
    @props.onChange(@state.currentTab)

  componentWillUnmount: ->
    window.removeEventListener 'hashchange', @handleHashChange


  # Helpers
  #
  getMenuOptionClassName: (option) ->
    cx(active: @state.currentTab == option)

  getCurrentTabName: ->
    @props.getCurrentTab() || location.hash.substr(1) || null

  getInitialTab: ->
    if @props.tabs.contains(currentTab = @getCurrentTabName())
      currentTab
    else
      @props.tabs.first()

  getTabOptions: ->
    @props.tabs.reduce (memo, tabName) =>
      memo[tabName] = @props.renderTabName(tabName)

      memo
    , {}


  # Handlers
  # 
  handleHashChange: ->
    if @props.tabs.contains(currentTab = @getCurrentTabName())
      @setState currentTab: currentTab
      @props.onChange(currentTab)

  handleSelect: (value) ->
    location.href = location.pathname + "#" + value


  # Renderers
  # 
  renderTabs: ->
    return null if @props.tabs.size == 1

    <ul>
      {
        @props.tabs.map (tabName) =>
          <li key = { tabName } className = { @getMenuOptionClassName(tabName) } >
            <a href = { location.pathname + "#" + tabName } className = "for-group" >
              { @props.renderTabName(tabName) }
            </a>
          </li>
        .toArray()
      }
    </ul>

  renderDropdownTabs: ->
    <Dropdown
      options  = { @getTabOptions() }
      value    = { @state.currentTab }
      onChange = { @handleSelect } />


  # Main render
  # 
  render: ->
    <nav className="tabs">
      { @renderTabs() }
      { @renderDropdownTabs() } 
    </nav>


# Exports
# 
module.exports = MainComponent
