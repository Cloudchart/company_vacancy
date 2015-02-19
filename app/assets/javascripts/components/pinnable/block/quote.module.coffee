# @cjsx React.DOM


# Components
#
Human = require('components/human')


# Exports
#
module.exports = React.createClass


  displayName: 'Quote'


  render: ->
    return null unless @props.item and @props.item.get('text', false)

    <section className="post-quote">
      <section className="quote" dangerouslySetInnerHTML={ __html: @props.item.get('text') } />
      <Human type="person" uuid={ @props.item.get('person_id') } />
    </section>
