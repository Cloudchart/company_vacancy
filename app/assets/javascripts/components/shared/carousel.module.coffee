# @cjsx React.DOM
#
Button = require('components/form/buttons').StandardButton


module.exports = React.createClass
  
  displayName: "Carousel"

  # Component Specifications
  # 
  propTypes:
    className:      React.PropTypes.string
    delay:          React.PropTypes.number
    showNavButtons: React.PropTypes.bool
    withSlideshow:  React.PropTypes.bool
    isSlideshowOn:  React.PropTypes.bool

  getDefaultProps: ->
    className:      ""
    delay:          7000
    showNavButtons: false
    withSlideshow:  false
    isSlideshowOn:  false

  getInitialState: ->
    position:       0
    isSliding:      false
    isTransitionOn: true
    isSlideshowOn:  @props.isSlideshowOn || @props.withSlideshow


  # Helpers
  #
  adjustOffset: ->
    if @state.position == -1 || @state.position == @getPositionsNumber()
      @setState
        isTransitionOn: false
        position:       (@state.position + @getPositionsNumber()) % @getPositionsNumber()
      setTimeout =>
        @setState(isTransitionOn: true)
      , 10

  showSlideshow: ->
    @props.withSlideshow && @getPositionsNumber() > 1

  getContainerLeft: ->
    slideOffset = if @showSlideshow() then 1 else 0

    -(@state.position + slideOffset) * 100/@getSlidesNumber()

  getContainerCSS: ->
    transform = "translate3d(#{@getContainerLeft()}%, 0px, 0px)"
    containerStyle = 
      transform:           transform
      WebkitTransform:     transform
      width:               "#{(@getSlidesNumber()) * 100}%"

  getSlidesNumber: ->
    @props.children.length + (if @showSlideshow() then 2 else 0)

  getPositionsNumber: ->
    @props.children.length

  getSlides: ->
    children = @props.children.map (child) => 
      React.addons.cloneWithProps(child, onNext: @navigateNext)

    if @showSlideshow()
      preSlide = React.addons.cloneWithProps(@props.children[@getPositionsNumber() - 1], onNext: @navigateNext)
      postSlide = React.addons.cloneWithProps(@props.children[0], onNext: @navigateNext)

      [preSlide].concat(children, postSlide)
    else
      children

  navigate: (direction) ->
    return null if @state.isSliding

    newPosition = if direction == 'prev'
      @state.position - 1
    else if direction == 'next'
      @state.position + 1

    @setState
      isSliding: true
      position: newPosition

  goToPosition: (newPosition) ->
    return null if @state.isSliding || newPosition == @state.position

    @setState
      isSliding:     true
      isSlideshowOn: false
      position:      newPosition

  navigateNext: ->
    @navigate("next")

  navigatePrev: ->
    @navigate("prev")


  # Handlers
  #
  handleClick: (index) ->
    @goToPosition(index)

  handleMouseOver: ->
    if @props.isSlideshowOn
      @setState(isSlideshowOn: false)

  handleMouseOut: ->
    if @props.isSlideshowOn
      @setState(isSlideshowOn: true)


  # Lifecycle methods
  #
  componentDidMount: ->
    $(@refs.container.getDOMNode()).on 'transitionend webkitTransitionEnd oTransitionEnd', =>
      @setState(isSliding: false)

      @adjustOffset()

    startSlideshow = =>
      setTimeout => 
        @navigate('next') if @state.isSlideshowOn
        startSlideshow()
      , @props.delay

    if @showSlideshow()
      startSlideshow()

  componentWillReceiveProps: (nextProps) ->
    @setState(isSlideshowOn: nextProps.isSlideshowOn)


  # Renderers
  #
  renderNavigation: ->
    return null unless @getPositionsNumber() > 1

    <ul className="navigation">
      { @renderSlideLinks() }
    </ul>

  renderPrevButton: ->
    return null unless @props.showNavButtons && @state.position != 0

    <Button
      className = "nav-button left"
      iconClass = "fa fa-chevron-left"
      onClick   = { @navigatePrev } />

  renderNextButton: ->
    return null unless @props.showNavButtons && @state.position != @getPositionsNumber() - 1

    <Button
      className = "nav-button right"
      iconClass = "fa fa-chevron-right"
      onClick   = { @navigateNext } />

  renderSlideLinks: ->
    @props.children.map (child, index) =>
      linkClassName = cx(active: index == @state.position)

      <li key={ index }>
        <button className={ linkClassName } onClick={ @handleClick.bind(@, index) } />
      </li>

  renderSlides: ->
    slideStyle =
      width: "#{100/@getSlidesNumber()}%"

    @getSlides().map (child, index) ->
      <li key={index} style={ slideStyle }>
        { child }
      </li>


  render: ->
    className = "carousel #{@props.className}".trim()

    className += ' no-transition' unless @state.isTransitionOn

    <div className={ className }>
      <ul className   = "container" 
          ref         = "container"
          style       = { @getContainerCSS() }
          onMouseOver = { @handleMouseOver }
          onMouseOut  = { @handleMouseOut } >
        { @renderSlides() }
      </ul>
      { @renderPrevButton() }
      { @renderNextButton() }
      { @renderNavigation() }
    </div>

