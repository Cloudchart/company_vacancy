# @cjsx React.DOM

# Exports
#
module.exports = React.createClass

  displayName: 'InsightTourLesson'

  getClassName: ->
    cx(
      "slide tour-insight-list": true
      active: @props.active
    )

  render: ->
    <article className={ @getClassName() }>
      <p>
        The link to your Insights board is at the top of the page; your insight can also be found next to the post you've commented on.
      </p>
    </article>