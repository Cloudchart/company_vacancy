# @cjsx React.DOM


cx = React.addons.classSet

TabShape = React.PropTypes.shape
  id:       React.PropTypes.string.isRequired
  title:    React.PropTypes.string.isRequired
  counter:  React.PropTypes.string

device = require('utils/device')

# Exports
#
module.exports = React.createClass

  displayName: 'TabNav'

  propTypes:
    tabs:         React.PropTypes.arrayOf(TabShape)
    onChange:     React.PropTypes.func.isRequired
    currentTab:   React.PropTypes.string


  getDefaultProps: ->
    currentTab: null


  # Handlers
  #

  handleChange: (id_or_event) ->
    id = if typeof id_or_event is 'string' then id_or_event else id_or_event.target.value
    window.location.hash = id
    @props.onChange(id) unless @props.currentTab == id


  # Lifecycle
  #
  componentDidMount: ->
    unless @props.currentTab
      tabFromHash = window.location.hash.split('#').pop()
      if tab = @props.tabs.find((tab) -> tab.id == tabFromHash)
        @handleChange(tab.id)
      else
        @handleChange(@props.tabs[0].id)


  # Render Tabs
  #

  renderTab: (tab) ->
    className = cx
      active: tab.id == @props.currentTab

    <li key={ tab.id } onClick={ @handleChange.bind(@, tab.id) } className={ className }>
      <span>{ tab.title }</span>
      <em>{ tab.counter }</em>
    </li>


  renderTabs: ->
    <ul>
      { @props.tabs.map @renderTab }
    </ul>


  # Render Select
  #

  renderOption: (tab) ->
    value = [tab.title, tab.counter].filter((part) -> !!part).join(' ')
    <option key={ tab.id } value={ tab.id}>
      { value }
    </option>


  renderSelect: ->
    <select value={ @props.currentTab } onChange={ @handleChange }>
      { @props.tabs.map @renderOption }
    </select>


  # Render
  #
  render: ->
    return null if @props.tabs.length < 2

    <nav className="tab-nav">
      { @renderTabs() }
      { @renderSelect() }
    </nav>
