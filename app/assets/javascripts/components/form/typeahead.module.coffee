# @cjsx React.DOM

cx = React.addons.classSet

Typeahead = React.createClass
  propTypes:
    options:           React.PropTypes.array
    value:             React.PropTypes.string

    onBlur:            React.PropTypes.func
    onChange:          React.PropTypes.func
    onOptionSelect:    React.PropTypes.func

    input:             React.PropTypes.func
    inputProps:        React.PropTypes.object

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

  navUp: ->
    @nav(-1)

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

  onEscape: ->
    @setSelectionIndex(null)
    @hideList()

  onKeyDown: (event) ->
    handler = @eventMap()[event.key]

    if handler
      handler(event)
      false

  onBlur: (event) ->
    if !@state.listHovered
      @props.onBlur()
      @hideList()

  onFocus: ->
    if @props.value.length > 0
      @showList()

  getDefaultProps: ->
    options: []
    value:   ""

    onBlur: (value) ->
    onChange: (value) ->
    onOptionSelect: (value) ->

  getInitialState: ->
    options:        @props.options
    selectionIndex: null
    showList:       false

  render: ->
    Input = @props.input

    <div className="typeahead">
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