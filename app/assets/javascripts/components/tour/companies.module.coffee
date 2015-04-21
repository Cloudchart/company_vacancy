# @cjsx React.DOM

cx = React.addons.classSet

# Exports
#
module.exports = React.createClass

  displayName: 'TourCompanies'

  propTypes:
    active: React.PropTypes.bool
    onNext: React.PropTypes.func

  getClassName: ->
    cx(
      "slide tour-companies": true
      active: @props.active
    )


  # Renderers
  #


  render: ->
    <article className={ @getClassName() }>
      <p>
        Learn from unicorns. Follow companies you're interested in to get their updates and watch them grow.
      </p>
      <section className="companies-list">
      </section>
    </article>