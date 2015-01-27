# @cjsx React.DOM

# Stores
#
PinStore = require('stores/pin_store')


# Components
#
ItemComponent = require('components/insite/item')


# Exports
#
module.exports = React.createClass

  displayName: 'InsiteList'
  
  
  gatherIds: ->
    @props.cursor

      .filter (item) =>
        item.get('pinnable_id')     is @props.pinnable_id     and
        item.get('pinnable_type')   is @props.pinnable_type   and
        not item.get('parent_id')                             and
        item.get('content')

      .sortBy (item) => item.get('created_at')
      
      .keySeq()

      .reverse()
  
  
  getDefaultProps: ->
    cursor: PinStore.cursor.items
  
  
  renderItems: (ids) ->
    ids.map (id) -> <ItemComponent key={ id } uuid={ id } cursor={ ItemComponent.getCursor(id) } />
  
  
  render: ->
    ids = @gatherIds()
    
    return null if ids.size == 0
    
    <ul className="insite-list">
      { @renderItems(ids).toArray() }
    </ul>
