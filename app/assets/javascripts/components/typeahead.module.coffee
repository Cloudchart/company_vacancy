# @cjsx React.DOM


# Constants
#
EmptyList = Immutable.List()


# Components
#

# Option Component
#
OptionComponent = React.createClass

  displayName: 'Option'


  getDefaultProps: ->
    value: ''


  render: ->
    return null unless @props.value

    <li onMouseEnter={ @props.onMouseEnter } onClick={ @props.onClick } style={ backgroundColor: if @props.selected then '#ccc' else '#eee' }>
      { @props.value }
    </li>


# Options List Component
#
OptionsListComponent = React.createClass

  displayName: 'OptionsList'


  handleMouseEnter: (index) ->
    @props.onChange(index) if typeof @props.onChange is 'function'


  handleClick: (index) ->
    @props.onClick(index) if typeof @props.onClick is 'function'


  getDefaultProps: ->
    options: EmptyList


  renderOption: (option, index) ->
    <OptionComponent
      onMouseEnter  = { @handleMouseEnter.bind(@, index) }
      onClick       = { @handleClick.bind(@, index) }
      key           = { option.id }
      value         = { option.value }
      selected      = { index == @props.index }
    />


  renderOptions: ->
    @props.options.map(@renderOption)


  render: ->

    return null if @props.options.size == 0

    <ul>
      { @renderOptions().toArray() }
    </ul>


# Exports
#
module.exports = React.createClass


  displayName: 'Typeahead'


  prev: ->
    @goto if @state.index? then @state.index - 1 else -Infinity


  next: ->
    @goto if @state.index? then @state.index + 1 else +Infinity


  goto: (index) ->
    return unless @state.active

    index = 0 if index > @state.options.size - 1
    index = @state.options.size - 1 if index < 0

    @setState
      index: index


  select: ->
    return unless @state.index isnt null
    return unless item = @state.options.get(@state.index)

    @refs['input'].getDOMNode().blur()

    @setState
      query: item.value

    if typeof @props.onValueChange is 'function'
      @props.onValueChange(item)


  handleQueryChange: (event) ->
    @setState
      query: event.target.value

    if typeof @props.onQueryChange is 'function'
      @props.onQueryChange(event.target.value)


  handleFocus: (event) ->
    @setState
      active: true


  handleBlur: (event) ->
    setTimeout =>
      @setState
        active: false
    , 100


  handleKeyDown: (event) ->
    switch event.key

      when 'Enter'
        event.preventDefault()
        event.stopPropagation()
        @select()

      when 'ArrowUp'
        event.preventDefault()
        @prev()

      when 'ArrowDown'
        event.preventDefault()
        @next()


  filterList: (list, query) ->
    query = query.toLowerCase()

    Immutable.List(list)
      .filter (item) =>
        item.value.toLowerCase().indexOf(query) >= 0


  getStateFromProps: (props) ->
    options = @filterList(props.list, props.query)

    options:  options
    query:    props.query
    index:    null


  componentWillReceiveProps: (nextProps) ->
    @setState @getStateFromProps(nextProps)


  getDefaultProps: ->
    options:    EmptyList
    query:      ''


  getInitialState: ->
    @getStateFromProps(@props)


  renderOptions: ->
    return null unless @state.active

    <OptionsListComponent onChange={ @goto } onClick={ @select } options={ @state.options } index={ @state.index } />


  render: ->
    <div className="cc-typeahead">
      <input
        ref         = 'input'
        value       = { @state.query }
        onFocus     = { @handleFocus }
        onBlur      = { @handleBlur }
        onChange    = { @handleQueryChange }
        onKeyDown   = { @handleKeyDown }
        placeholder = { @props.placeholder }
      />
      { @renderOptions() }
    </div>
