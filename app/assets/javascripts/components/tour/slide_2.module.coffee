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
    <article className="slide slide-2">
      <p>
        Learn from unicorns. Follow companies you're interested in to get their updates and watch them grow.
      </p>
      <section className="companies-list">
        <article className="company-preview" />
        <article className="company-preview" />
      </section>
    </article>