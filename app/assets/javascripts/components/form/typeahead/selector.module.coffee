# @cjsx React.DOM

TypeaheadOption = require('components/form/typeahead/option')

TypeaheadSelector = React.createClass
  propTypes:
    options:          React.PropTypes.array
    selectionIndex:   React.PropTypes.number
    onOptionSelected: React.PropTypes.func
    renderOption:     React.PropTypes.func
    onMouseEnter:     React.PropTypes.func
    onMouseLeave:     React.PropTypes.func
    showList:         React.PropTypes.bool

  setSelectionIndex: (index) ->
    @setState
      selectionIndex: index
      selection:      @getSelectionForIndex(index)

  getSelectionForIndex: (index) ->
    @props.options[index] || null

  nav: (delta) ->
    length = @props.options.length

    if @state.selectionIndex == null
      currentIndex = if delta > 0 then 0 else (length - 1)
      delta = 0
    else
      currentIndex = @state.selectionIndex

    newIndex = currentIndex + delta
    newIndex = Math.abs((newIndex + length) % length)

    newSelection = @getSelectionForIndex(newIndex)
    @setState
      selectionIndex: newIndex
      selection:      newSelection

  navDown: ->
    @nav(1)

  navUp: ->
    @nav(-1)

  onClick: (result) ->
    @props.onOptionSelected(result)
    false

  onHover: (index) ->
    @setSelectionIndex(index)

  onMouseEnter: ->
    @props.onMouseEnter()

  onMouseLeave: ->
    @props.onMouseLeave()

  getDefaultProps: ->
    selectionIndex:   null
    onOptionSelected: (option) ->
    options:          []

  getInitialState: ->
    selectionIndex: @props.selectionIndex
    selection:      @getSelectionForIndex(@props.selectionIndex)

  render: ->
    if @props.showList
      results = @props.options.map (result, index) =>
        <TypeaheadOption 
          key     = {index}
          hover   = {@state.selectionIndex == index}
          onClick = {@onClick.bind(this, result)}
          onHover = {@onHover.bind(this, index)} >
          { @props.renderOption(result) }
        </TypeaheadOption>
    else
      results = []

    <ul className='typeahead-selector'
        onMouseEnter={@onMouseEnter}
        onMouseLeave={@onMouseLeave}>{ results }</ul>

module.exports = TypeaheadSelector
