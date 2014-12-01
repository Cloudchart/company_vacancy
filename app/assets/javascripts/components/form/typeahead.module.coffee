# @cjsx React.DOM

cx = React.addons.classSet

TypeaheadSelector = require('components/form/typeahead/selector')

KeyCodes          = require('utils/key_codes')

Typeahead = React.createClass
  propTypes:
    options:           React.PropTypes.array
    maxOptions:        React.PropTypes.number
    value:             React.PropTypes.string

    onBlur:            React.PropTypes.func
    onChange:          React.PropTypes.func
    onOptionSelect:    React.PropTypes.func

    input:             React.PropTypes.func
    inputProps:        React.PropTypes.object

    getOptionValue:    React.PropTypes.func
    filterOption:      React.PropTypes.func
    renderOption:      React.PropTypes.func

  getOptionsForValue: (value, options) ->
    options = _.chain(options)
      .filter((option) => @props.filterOption(option, value))
      .value()

    if @props.maxOptions
      options = options.slice(0, @props.maxOptions)

    options

  renderIncrementalSearchResults: ->
    <TypeaheadSelector
      ref="sel"
      options          = {@state.visible}
      onOptionSelected = {@onOptionSelected}
      renderOption     = {@props.renderOption}
      onMouseEnter     = {@onMouseEnter}
      onMouseLeave     = {@onMouseLeave}
      showList         = {@state.showList}
    />

  hideList: ->
    @setState
      showList: false
      listHovered: false

  showList: ->
    @setState
      showList: true

  onMouseEnter: ->
    @setState
      listHovered: true

  onMouseLeave: ->
    @setState
      listHovered: false

  onOptionSelected: (option) ->
    value = @props.getOptionValue(option)
    @props.onOptionSelect(value)

    @setState
      visible: @getOptionsForValue(value, @state.options)
      selection: value
      showList: false

    @props.onOptionSelected(option)


  eventMap: (e) ->
    events = {}

    events[KeyCodes.UP] = @refs.sel.navUp
    events[KeyCodes.DOWN] = @refs.sel.navDown
    events[KeyCodes.RETURN] = events[KeyCodes.ENTER] = @onEnter
    events[KeyCodes.ESCAPE] = @onEscape
    events[KeyCodes.TAB] = @onTab

    events

  onChange: (event) ->
    value = event.target.value
    @props.onChange(value)
    @setState
      visible: @getOptionsForValue(value, @state.options)
      selection: null
      value: value
      showList: value.length > 0
    
    false

  onEnter: (event) ->
    if !@refs.sel.state.selection
      return @props.onKeyDown(event)

    @onOptionSelected(@refs.sel.state.selection)

  onEscape: ->
    @refs.sel.setSelectionIndex(null)
    @hideList()

  onKeyDown: (event) ->
    handler = @eventMap()[event.keyCode]

    if handler
      handler(event)
      false
    else
      @props.onKeyDown(event)

  onBlur: (event) ->
    if !@state.listHovered
      @props.onBlur()
      @hideList()

  onFocus: ->
    if @props.value.length > 0
      @showList()

  getDefaultProps: ->
    options: []
    value: ""
    placeholder: ""
    onKeyDown: (event) -> return true
    onOptionSelected: (option) ->
    listHovered: false

    getOptionValue: (option) -> option
    filterOption: (option, query) -> 
      option.toLowerCase().indexOf(query.toLowerCase) == 0

    renderOption: (option) -> option

  getInitialState: ->
    options:   @props.options
    visible:   @getOptionsForValue(@props.value, @props.options)
    selection: null
    showList:  false

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
        errors      = {@props.inputProps.errors}
        type        = {@props.inputProps.type} />
      { @renderIncrementalSearchResults() }
    </div>

module.exports = Typeahead