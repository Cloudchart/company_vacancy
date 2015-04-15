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

  propTypes:
    limit:      React.PropTypes.number

  getDefaultProps: ->
    cursor:     PinStore.cursor.items
    limit:      0


  # Helpers
  #
  gatherIds: ->
    PinStore
      .filterInsightsForPost(@props.pinnable_id)
      .sortBy (item) => item.get('created_at')
      .keySeq()
      .reverse()


  # Renderers
  #
  renderItems: (ids) ->
    ids = ids.take(@props.limit) if @props.limit > 0

    ids.map (id) => 
      <li key={ id }>
        <ItemComponent key={ id } uuid={ id } cursor={ ItemComponent.getCursor(id) } />
      </li>
    .toArray()


  render: ->
    ids = @gatherIds()

    return null if ids.size == 0

    <ul className="insight-list">
      { @renderItems(ids) }
    </ul>      
    
