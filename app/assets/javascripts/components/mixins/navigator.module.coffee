# @cjsx React.DOM

Button = require('components/form/buttons').StandardButton

module.exports =

  propTypes:
    showNavButtons: React.PropTypes.bool

  getInitialState: ->
    isNavigating:   false
    position:       0
    isNexted:       true


  # Helpers
  #
  navigate: (direction, stateChanges={}) ->
    return if @state.isNavigating

    newPosition = if direction == 'prev'
      @state.position - 1
    else if direction == 'next'
      @state.position + 1

    return if !stateChanges.cycle && (newPosition > @getPositionsNumber() - 1 || newPosition < 0)

    @setState _.extend(stateChanges, position: newPosition, isNexted: direction == 'next')

  goToNext: (stateChanges={}) ->
    @navigate("next", stateChanges)

  goToPrev: (stateChanges={}) ->
    @navigate("prev", stateChanges)

  goToPosition: (newPosition, stateChanges={}) ->
    return if @state.isNavigating || newPosition == @state.position

    @setState _.extend(stateChanges, position: newPosition, isNexted: (newPosition - @state.position == 1))


  # Handlers
  #
  handleNavLinkClick: (index) ->
    state = if @getNavigationClickState then @getNavigationClickState() else {}

    @goToPosition(index, state)

  handleNextButtonClick: ->
    state = if @getNavigationClickState then @getNavigationClickState() else {}

    @navigate("next", state)

  handlePrevButtonClick: ->
    state = if @getNavigationClickState then @getNavigationClickState() else {}
    
    @navigate("prev", state)


  # Renderers
  #
  renderNavLinks: ->
    [0..@getPositionsNumber()-1].map (index) =>
      linkClassName = cx(active: index == @state.position % @getPositionsNumber())

      <li key={ index }>
        <button className={ linkClassName } onClick={ @handleNavLinkClick.bind(@, index) } />
      </li>

  renderNavigation: ->
    return null unless @getPositionsNumber() > 1

    <ul className="navigation">
      { @renderNavLinks() }
    </ul>

  renderPrevButton: ->
    return null if @state.position == 0

    <Button
      className = "nav-button left"
      iconClass = "fa fa-chevron-left"
      onClick   = { @handlePrevButtonClick } />

  renderNextButton: ->
    return null if @state.position == @getPositionsNumber() - 1

    <Button
      className = "nav-button right"
      iconClass = "fa fa-chevron-right"
      onClick   = { @handleNextButtonClick } />

