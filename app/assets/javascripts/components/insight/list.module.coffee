# @cjsx React.DOM

# Stores
#
PinStore = require('stores/pin_store')


# Components
#
ItemComponent = require('components/insight/item')


# Exports
#
module.exports = React.createClass

  displayName: 'InsightList'


  gatherIds: ->
    PinStore
      .filterInsightsForPost(@props.pinnable_id)

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

    <ul className="insight-list">
      { @renderItems(ids).toArray() }
    </ul>
