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
    onlyFirst: React.PropTypes.bool

  getDefaultProps: ->
    cursor: PinStore.cursor.items
    onlyFirst: false

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
    ids = ids.take(1) if @props.onlyFirst

    ids.map (id) -> <ItemComponent key={ id } uuid={ id } cursor={ ItemComponent.getCursor(id) } />


  render: ->
    ids = @gatherIds()

    return null if ids.size == 0

    <ul className="insight-list">
      { @renderItems(ids).toArray() }
    </ul>
