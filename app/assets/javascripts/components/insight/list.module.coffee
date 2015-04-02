# @cjsx React.DOM

# Stores
#
PinStore = require('stores/pin_store')


# Components
#
Carousel      = require('components/shared/carousel')
ItemComponent = require('components/insight/item')


# Exports
#
module.exports = React.createClass

  displayName: 'InsightList'

  propTypes:
    isCarousel: React.PropTypes.bool
    limit:      React.PropTypes.number

  getDefaultProps: ->
    isCarousel: false
    cursor:     PinStore.cursor.items
    limit:      0

  getInitialState: ->
    isSlideshowOn: false


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
      item = <ItemComponent key={ id } uuid={ id } cursor={ ItemComponent.getCursor(id) } />

      unless @props.isCarousel
        item = <li key={ id }>{ item }</li>

      item
    .toArray()


  render: ->
    ids = @gatherIds()

    return null if ids.size == 0

    if @props.isCarousel
      <Carousel className = "insight-list">
        { @renderItems(ids) }
      </Carousel>
    else
      <ul className="insight-list">
        { @renderItems(ids) }
      </ul>      
    
