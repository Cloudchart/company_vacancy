# @cjsx React.DOM

cx = React.addons.classSet

# Exports
#
module.exports = React.createClass


  displayName: 'Paragraph'


  render: ->
    return null unless @props.text

    classes = cx
      'paragraph': true
      'truncated': @props.truncated

    <section className={ classes } dangerouslySetInnerHTML={ __html: @props.text } />
