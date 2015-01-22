# @cjsx React.DOM


# Stores
#
PictureStore = require('stores/picture_store.cursor')


# Exports
#
module.exports = React.createClass


  getDefaultProps: ->
    cursor:     PictureStore.cursor.items
  
  
  getInitialState: ->
    picture: @props.cursor.filter((p) => p.get('owner_id') == @props.uuid).first()
  

  render: ->
    source = @state.picture.get('url') if @state.picture

    <div className="picture">
      <img src={ source } />
    </div>
