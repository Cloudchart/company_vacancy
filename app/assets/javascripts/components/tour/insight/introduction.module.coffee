# @cjsx React.DOM

# Exports
#
module.exports = React.createClass

  displayName: 'InsightTourIntroduction'

  getClassName: ->
    cx(
      "slide tour-insight-introduction": true
      active: @props.active
    )

  render: ->
    <article className={ @getClassName() }>
      <p>
        Looks like you're about to add your first insight. 
        It's a short actionable comment that you add to posts when saving them to your board.
      </p>
    </article>