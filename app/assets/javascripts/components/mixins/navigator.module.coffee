# @cjsx React.DOM

Button = require('components/form/buttons').StandardButton

module.exports =

  propTypes:
    showNavButtons: React.PropTypes.bool

  getDefaultProps: ->
    showNavButtons: false

  getInitialState: ->
    isNavigating:   false
    position:       0


  # Handlers
  #
  handleNavLinkClick: (index) ->
    @goToPosition(index, @getNavigationClickState())

  handleNextButtonClick: ->
    @navigate("next", @getNavigationClickState())

  handlePrevButtonClick: ->
    @navigate("prev", @getNavigationClickState())


  # Helpers
  #
  navigate: (direction, stateChanges={}) ->
    return null if @state.isNavigating

    newPosition = if direction == 'prev'
      @state.position - 1
    else if direction == 'next'
      @state.position + 1

    @setState _.extend(stateChanges, position: newPosition)

  goToNext: (stateChanges={}) ->
    @navigate("next", stateChanges)

  goToPrev: (stateChanges={}) ->
    @navigate("prev", stateChanges)

  goToPosition: (newPosition, stateChanges={}) ->
    return null if @state.isNavigating || newPosition == @state.position

    @setState _.extend(stateChanges, position: newPosition)


  # Renderers
  #
  renderNavLinks: ->
    @props.children.map (child, index) =>
      linkClassName = cx(active: index == @state.position)

      <li key={ index }>
        <button className={ linkClassName } onClick={ @handleNavLinkClick.bind(@, index) } />
      </li>

  renderNavigation: ->
    return null unless @getPositionsNumber() > 1

    <ul className="navigation">
      { @renderNavLinks() }
    </ul>

  renderPrevButton: ->
    return null unless @props.showNavButtons && @state.position != 0

    <Button
      className = "nav-button left"
      iconClass = "fa fa-chevron-left"
      onClick   = { @handlePrevButtonClick } />

  renderNextButton: ->
    return null unless @props.showNavButtons && @state.position != @getPositionsNumber() - 1

    <Button
      className = "nav-button right"
      iconClass = "fa fa-chevron-right"
      onClick   = { @handleNextButtonClick } />

