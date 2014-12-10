# @cjsx React.DOM

cx = React.addons.classSet

Typeahead = React.createClass

  renderOptions: ->
    if @state.showList
      results = @props.options.map (option, index) =>
        <li 
          key          = {index}
          className    = {cx(hover: @state.selectionIndex == index)}
          onClick      = {@onOptionSelect.bind(this, option.value)}
          onMouseEnter = {@setSelectionIndex.bind(this, index)} >
          { option.content }
        </li>
    else
      results = []

    <ul className='typeahead-selector'
        onMouseEnter={@onMouseEnter}
        onMouseLeave={@onMouseLeave}>{ results }</ul>

  showList: ->
    @setState
      showList: true

  hideList: ->
    @setState
      showList: false
      listHovered: false
      selectionIndex: null

  setSelectionIndex: (index) ->
    @setState
      selectionIndex: index

  getSelectionForIndex: (index) ->
    if index != null
      @props.options[index].value
    else
      null

  nav: (delta) ->
    length = @props.options.length

    if @state.selectionIndex == null
      currentIndex = if delta > 0 then 0 else (length - 1)
      delta = 0
    else
      currentIndex = @state.selectionIndex

    newIndex = currentIndex + delta
    newIndex = Math.abs((newIndex + length) % length)

    @setSelectionIndex(newIndex)

  navDown: ->
    @nav(1)
    false

  navUp: ->
    @nav(-1)
    false

  onMouseEnter: ->
    @setState
      listHovered: true

  onMouseLeave: ->
    @setState
      listHovered: false

  onOptionSelect: (value) ->
    @hideList()
    @props.onOptionSelect(value)

  eventMap: (e) ->
    ArrowUp   : @navUp
    ArrowDown : @navDown
    Enter     : @onEnter
    Escape    : @onEscape
    Tab       : @onTab

  onChange: (event) ->
    value = event.target.value
    @props.onChange(value)
    @setState
      selectionIndex: null
      showList:       value.length > 0
    
    false

  onEnter: ->
    if @state.selectionIndex != null
      @onOptionSelect(@getSelectionForIndex(@state.selectionIndex))
      false

  onTab: ->
    if @props.options.length > 0 && @state.showList
      @onOptionSelect(@getSelectionForIndex(0))
      false

  onEscape: ->
    @setSelectionIndex(null)
    @hideList()
    false

  onKeyDown: (event) ->
    handler = @eventMap()[event.key]

    if handler
      handler(event)

  onBlur: (event) ->
    if !@state.listHovered
      @props.onBlur()
      @hideList()

  onFocus: ->
    if @props.value.length > 0
      @showList()

  propTypes:
    className:         React.PropTypes.string
    options:           React.PropTypes.array
    value:             React.PropTypes.string

    onBlur:            React.PropTypes.func
    onChange:          React.PropTypes.func
    onOptionSelect:    React.PropTypes.func

    input:             React.PropTypes.func
    inputProps:        React.PropTypes.object

  getDefaultProps: ->
    className: ""
    options:   []
    value:     ""

    onBlur: (value) ->
    onChange: (value) ->
    onOptionSelect: (value) ->

  getInitialState: ->
    options:        @props.options
    selectionIndex: null
    showList:       false

  render: ->
    Input     = @props.input
    className = (@props.className + " typeahead").trim()

    <div className={className}>
      <Input
        onFocus      = {@onFocus}
        onBlur       = {@onBlur}
        onChange     = {@onChange}
        onKeyDown    = {@onKeyDown}
        value        = {@props.value} 

        placeholder = {@props.inputProps.placeholder}
        errors      = {@props.inputProps.errors} />
      { @renderOptions() }
    </div>

module.exports = Typeahead