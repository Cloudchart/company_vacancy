# @cjsx React.DOM


# Stores
#
ParagraphStore = require('stores/paragraph_store.cursor')


# Exports
#
module.exports = React.createClass


  getDefaultProps: ->
    className: 'paragraph'
    cursor:     ParagraphStore.cursor.items
  
  
  getInitialState: ->
    paragraph: @props.cursor.filter((p) => p.get('owner_id') == @props.uuid).first()
  

  render: ->
    content = @state.paragraph.get('content') if @state.paragraph

    <div className={ @props.className.toLowerCase() } dangerouslySetInnerHTML={ __html: content } />
