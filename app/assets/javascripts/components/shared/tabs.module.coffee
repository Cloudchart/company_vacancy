# @cjsx React.DOM

# Imports
#


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


  # Handlers
  # 
  handleHashChange: ->
    if @props.tabs.contains(currentTab = @getCurrentTabName())
      @setState currentTab: currentTab
      @props.onChange(currentTab)


  # Renderers
  # 
  renderTabs: ->
    return null if @props.tabs.size == 1

    @props.tabs.map (tabName) =>
      <li key = { tabName } className = { @getMenuOptionClassName(tabName) } >
        <a href = { location.pathname + "#" + tabName } className = "for-group" >
          { @props.renderTabName(tabName) }
        </a>
      </li>
    .toArray()


  # Main render
  # 
  render: ->
    <nav className="tabs">
      <ul>
        { @renderTabs() }
      </ul>
    </nav>


# Exports
# 
module.exports = MainComponent
