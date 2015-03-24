# @cjsx React.DOM
#

module.exports = React.createClass
  
  displayName: "Carousel"

  # Component Specifications
  # 
  propTypes:
    className:      React.PropTypes.string

  getDefaultProps: ->
    className:      ""

  getInitialState: ->
    position:      0
    isAnimating:   false


  # Helpers
  #
  getContainerLeft: ->
    -@state.position * 100/@getSlidesNumber()

  getContainerCSS: ->
    transform = "translate3d(#{@getContainerLeft()}%, 0px, 0px)"
    containerStyle = 
      transform:           transform
      WebkitTransform:     transform
      width:               "#{(@getSlidesNumber()) * 100}%"

  getSlidesNumber: ->
    @props.children.length

  goToPosition: (newPosition) ->
    return null if @state.isAnimating || newPosition == @state.position

    @setState
      isAnimating: true
      position:    newPosition

  # Handlers
  #
  handleClick: (index) ->
    @goToPosition(index)

  # Lifecycle methods
  #
  componentDidMount: ->
    $(@refs.container.getDOMNode()).on 'transitionend webkitTransitionEnd oTransitionEnd', =>
      @setState(isAnimating: false)


  # Renderers
  #
  renderNavigation: ->
    return null unless @props.children.length > 1

    <ul className="navigation">
      { @renderSlideLinks() }
    </ul>

  renderSlideLinks: ->
    @props.children.map (child, index) =>
      linkClassName = cx(active: index == @state.position)

      <li key={ index } >
        <button className={ linkClassName } onClick={ @handleClick.bind(@, index) } />
      </li>

  renderSlides: ->
    slideStyle =
      width: "#{100/@getSlidesNumber()}%"

    @props.children.map (child, index) ->
      <li key={index} style={ slideStyle }>
        { child }
      </li>


  render: ->
    className = "carousel #{@props.className}".trim()

    <div className={ className }>
      <ul className="container" ref="container" style={ @getContainerCSS() }>
        { @renderSlides() }
      </ul>
      { @renderNavigation() }
    </div>

