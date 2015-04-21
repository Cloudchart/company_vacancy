# @cjsx React.DOM
#
NavigatorMixin = require('components/mixins/navigator')


module.exports = React.createClass
  
  displayName: "Carousel"

  mixins: [NavigatorMixin]

  # Component Specifications
  # 
  propTypes:
    className:          React.PropTypes.string
    delay:              React.PropTypes.number
    withSlideshow:      React.PropTypes.bool
    isSlideshowPaused:  React.PropTypes.bool

  getDefaultProps: ->
    className:           ""
    delay:               7000
    withSlideshow:       false
    isSlideshowPaused:   true

  getInitialState: ->
    isTransitionOn:     true
    isSlideshowStopped: !@props.withSlideshow
    isSlideshowPaused:  !@props.withSlideshow || @props.isSlideshowPaused


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
    if @showSlideshow()
      preSlide = React.addons.cloneWithProps(@props.children[@getPositionsNumber() - 1])
      postSlide = React.addons.cloneWithProps(@props.children[0])

      [preSlide].concat(@props.children, postSlide)
    else
      @props.children


  # Handlers
  #
  getNavigationClickState: ->
    isNavigating:       true
    isSlideshowStopped: true

  handleMouseOver: ->
    if !@props.isSlideshowPaused
      @setState(isSlideshowPaused: true)

  handleMouseOut: ->
    if !@props.isSlideshowPaused
      @setState(isSlideshowPaused: false)


  # Lifecycle methods
  #
  componentDidMount: ->
    $(@refs.container.getDOMNode()).on 'transitionend webkitTransitionEnd oTransitionEnd', =>
      @setState(isNavigating: false)

      @adjustOffset()

    startSlideshow = =>
      setTimeout => 
        @goToNext(isNavigating: true) unless @state.isSlideshowPaused || @state.isSlideshowStopped
        startSlideshow() unless @state.isSlideshowStopped
      , @props.delay

    if @showSlideshow()
      startSlideshow()

  componentWillReceiveProps: (nextProps) ->
    @setState(isSlideshowPaused: nextProps.isSlideshowPaused)


  # Renderers
  #
  renderSlides: ->
    slideStyle =
      width: "#{100/@getSlidesNumber()}%"

    @getSlides().map (child, index) ->
      <li key={index} style={ slideStyle }>
        { child }
      </li>


  render: ->
    className = "carousel navigator #{@props.className}".trim()

    className += ' no-transition' unless @state.isTransitionOn

    <div className={ className }>
      <ul className   = "container" 
          ref         = "container"
          style       = { @getContainerCSS() }
          onMouseOver = { @handleMouseOver }
          onMouseOut  = { @handleMouseOut } >
        { @renderSlides() }
      </ul>
      { @renderNavigation() }
    </div>

