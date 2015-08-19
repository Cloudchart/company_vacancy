# @cjsx React.DOM

# Exports
#
module.exports = React.createClass

  displayName: 'StarInsights!'

  # Render
  #
  render: ->
    <section className="cc-container-common">
      <section className="star-insights">
        <i className="fa fa-star-o" />
        <p>
          <strong>Star insights you like!</strong>
          They will be added to your profile so you will never lose them.
        </p>
      </section>
    </section>
