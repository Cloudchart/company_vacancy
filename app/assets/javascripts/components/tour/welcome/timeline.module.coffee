# @cjsx React.DOM

cx = React.addons.classSet

# Exports
#
module.exports = React.createClass

  displayName: 'WelcomeTourTimeline'

  propTypes:
    active:           React.PropTypes.bool
    isInsightFocused: React.PropTypes.bool

  getDefaultProps: ->
    isInsightFocused: false
    isTransitionOff:  true

  getInitialState: ->
    arePostsScrolled: false


  getClassName: ->
    cx(
      "slide tour-timeline": true
      active:                @props.active
      scrolled:              @state.arePostsScrolled
      "insight-focused":     @state.isInsightFocused
      "no-transition":       @state.isTransitionOff
    )



  # Lifecycle methods
  #
  componentWillReceiveProps: (nextProps) ->
    if @props.active && nextProps.active && nextProps.isInsightFocused
      @setState isInsightFocused: true

    if @props.active && nextProps.active && !nextProps.isInsightFocused
      @setState isInsightFocused: false

    if !@props.active && nextProps.active
      if !nextProps.isInsightFocused
        setTimeout =>
          @setState
            arePostsScrolled: true
            isTransitionOff:  false
        , 1000
      else
        @setState arePostsScrolled: true

        setTimeout =>
          @setState
            isInsightFocused: true
            isTransitionOff:  false
        , 500

    if @props.active && !nextProps.active
      setTimeout =>
        @setState
          arePostsScrolled: false
          isInsightFocused: false
          isTransitionOff:  true
      , 500


  # Renderers
  #
  render: ->
    <article className={ @getClassName() }>
      <p>
        Browse unicorns' milestones in company timeline and discover actionable insights by founders, investors, and experts — or, add your own.
      </p>
      <section className="timeline">
        <div className="container">
          <article className="posts" />
          <article className="insight" />
        </div>
      </section>
    </article>