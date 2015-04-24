# @cjsx React.DOM

# Imports
# 
Timeline = require('components/company/timeline')


# Utils
#
cx = React.addons.classSet


# Main component
# 
MainComponent = React.createClass

  displayName: 'CompanyMainNav'
  # mixins: []
  # statics: {}
  propTypes:
    onChange: React.PropTypes.func.isRequired
    canEdit: React.PropTypes.bool.isRequired


  # Component Specifications
  # 
  # getDefaultProps: ->

  getInitialState: ->
    currentTab: @getInitialTab()

  
  # Lifecycle Methods
  # 
  # componentWillMount: ->

  componentDidMount: ->
    window.addEventListener 'hashchange', @handleHashChange
    @props.onChange(@state.currentTab)

  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->

  componentWillUnmount: ->
    window.removeEventListener 'hashchange', @handleHashChange


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

  getMenuOptionClassName: (option) ->
    cx(active: @state.currentTab == option)

  getCurrentTabName: ->
    tabName = location.hash.substr(1) || null
    return 'timeline' if tabName and tabName.match(/^#story/)
    tabName

  getInitialTab: ->
    visibleTabs = @getVisibleTabs()

    if visibleTabs.contains(currentTab = @getCurrentTabName())
      currentTab
    else
      visibleTabs.first()


  # Handlers
  # 
  handleHashChange: ->
    if @getVisibleTabs().contains(currentTab = @getCurrentTabName())
      @setState currentTab: currentTab
      @props.onChange(currentTab)


  # Renderers
  # 
  renderTabs: ->
    @getVisibleTabs().map (tabName) =>
      <li key = { tabName } className = { @getMenuOptionClassName(tabName) } >
        <a href = { location.pathname + "#" + tabName } className = "for-group" >
          { tabName }
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
