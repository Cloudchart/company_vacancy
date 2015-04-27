# @cjsx React.DOM

cx = React.addons.classSet

# Exports
#
module.exports = React.createClass

  displayName: 'WelcomeTourTimeline'

  propTypes:
    active:           React.PropTypes.bool
    className:        React.PropTypes.string
    isInsightFocused: React.PropTypes.bool
    isAnimated:       React.PropTypes.bool

  getDefaultProps: ->
    isInsightFocused: false
    isTransitionOff:  true

  getInitialState: ->
    arePostsScrolled: false


  getClassName: ->
    cx(
      scrolled:              @state.arePostsScrolled
      "insight-focused":     @state.isInsightFocused
    )


  # Lifecycle methods
  #
  componentWillReceiveProps: (nextProps) ->
    if !@props.active && nextProps.active
      @setState
        arePostsScrolled: true
        isInsightFocused: nextProps.isInsightFocused
    else if @props.active && !nextProps.active
      @setState
        arePostsScrolled: false

      setTimeout =>
        @setState isInsightFocused: false
      , 500
    else
      @setState isInsightFocused: nextProps.isInsightFocused


  # Renderers
  #
  render: ->
    <article className={ "tour-timeline " + @props.className + " " + @getClassName() }>
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