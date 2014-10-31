# @cjsx React.DOM

module.exports = 

  handleSortableChange: (key, currIndex, nextIndex) ->
    console.log 'handleSortableChange'

  handleSortableUpdate: ->
    console.log 'handleSortableUpdate'

  handlePlaceholderClick: (position) ->
    @setState({ position: position })

  handleCancelBlockCreateClick: ->
    @setState({ position: null })

  # Section Placeholder component
  #
  SectionPlaceholderComponent: (position) ->
    cancel_item = =>
      <li key="cancel" className="cancel">
        <i className="fa fa-times-circle" onClick={@handleCancelBlockCreateClick.bind(@, position)} />
      </li>
    
    item = (type, key) =>
      <li key={key} onClick={@handleChooseBlockTypeClick.bind(@, type)}>{key}</li>
    
    content = unless @state.company.flags.is_read_only
      if @state.position == position
        items = _.map(@identityTypes(), item) ; items.push(cancel_item())
        <ul>{items}</ul>
      else
        <figure onClick={@handlePlaceholderClick.bind(@, position)}>
          <i className="fa fa-plus" />
        </figure>
    
    <section className="placeholder">{content}</section>
