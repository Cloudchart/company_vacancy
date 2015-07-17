# @cjsx React.DOM

# Exports
#
module.exports = React.createClass

  displayName: 'InsightTourLesson'

  propTypes:
    className: React.PropTypes.string

  render: ->
    <article className={ "tour-insight-lesson " + @props.className }>
      <p>
        An insight is always something that can be put to action — a concise and useful idea for the founders' community.
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