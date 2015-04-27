# @cjsx React.DOM

# Exports
#
module.exports = React.createClass

  displayName: 'InsightTourIntroduction'

  propTypes:
    className: React.PropTypes.string

  render: ->
    <article className={ "tour-insight-introduction " + @props.className }>
      <p>
        Looks like you're about to add your first insight. 
        It's a short actionable comment that you add to posts when saving them to your board.
      </p>
      <div className="pin-form-placeholder"></div>
    </article>