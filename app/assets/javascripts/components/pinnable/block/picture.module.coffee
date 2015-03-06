# @cjsx React.DOM


# Exports
#
module.exports = React.createClass


  displayName: 'Picture'


  render: ->
    return null unless @props.item and @props.item.get('url', false)

    <section className="picture">
      <img src={ @props.item.get('url') } width="100%" />
    </section>
