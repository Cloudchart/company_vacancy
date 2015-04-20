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
    <article className="slide slide-5">
      <p>
        Make yourself valuable to founder community.
      </p>
      <section className="insight-guide">
        <article className="insight" />
        <div className="invalid">
          “Hey, nice tutorial you've got!”
          <hr />
        </div>
        <p className="valid">
          “When doing online tutorial for  a product, try to keep it  under 5 screens max.”
          <i className="fa fa-check" />
        </p>
      </section>
    </article>