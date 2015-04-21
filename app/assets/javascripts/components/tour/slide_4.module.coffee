# @cjsx React.DOM



# Exports
#
module.exports = React.createClass

  displayName: 'Slide2'

  propTypes:
    onNext: React.PropTypes.func

  getInitialState: ->
    isActive: false


  getInsightClass: ->
    if @state.isActive then 'insight active' else 'insight'


  # Lifecycle methods
  #
  componentDidMount: ->
    changeActive = =>
      setTimeout =>
        if @isMounted()
          @setState isActive: !@state.isActive
          changeActive()
      , 2000

    changeActive()


  # Renderers
  #
  render: ->
    <article className="slide slide-4">
      <p>
        Put the insights to action. Use them to grow your own business. Press the <i className="fa fa-thumb-tack" /> button to pin an insight and it will be saved to your profile.
      </p>
      <section className={ @getInsightClass() }>
      </section>
    </article>