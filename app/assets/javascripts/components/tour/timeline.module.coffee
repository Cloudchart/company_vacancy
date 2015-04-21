# @cjsx React.DOM



# Exports
#
module.exports = React.createClass

  displayName: 'Slide2'

  propTypes:
    onNext: React.PropTypes.func


  # Lifecycle methods
  #


  # Renderers
  #
  render: ->
    <article className="slide slide-3">
      <p>
        Browse unicorns' milestones in company timeline and discover actionable insights by founders, investors, and experts — or, add your own.
      </p>
      <section className="tour-timeline">
        <article className="tour-post" />
        <article className="tour-insight" />
      </section>
    </article>