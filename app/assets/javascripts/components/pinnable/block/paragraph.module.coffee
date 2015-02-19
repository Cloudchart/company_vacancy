# @cjsx React.DOM


# Exports
#
module.exports = React.createClass


  displayName: 'Paragraph'


  render: ->
    return null unless @props.item and @props.item.get('content', false)

    <section className="paragraph" dangerouslySetInnerHTML={ __html: @props.item.get('content') } />
