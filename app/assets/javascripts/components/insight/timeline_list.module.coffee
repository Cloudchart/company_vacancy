# @cjsx React.DOM

cx = React.addons.classSet

# Stores
#
PinStore   = require('stores/pin_store')
UserStore  = require('stores/user_store.cursor')

# Components
#
ItemComponent = require('components/insight/item')
Avatar        = require('components/avatar')


# Exports
#
module.exports = React.createClass

  displayName: 'InsightTimelineList'

  getDefaultProps: ->
    cursor:         PinStore.cursor.items

  getInitialState: ->
    currentIndex: 0


  # Helpers
  #
  gatherInsights: ->
    PinStore
      .filterInsightsForPost(@props.pinnable_id)
      .sortBy (item) => item.get('created_at')
      .reverse()
      .take(3)

  gatherInsighters: (insights) ->
    insights
      .map (insight) -> insight.get('user_id')
      .map (user_id) -> UserStore.get(user_id)


  # Handlers
  #
  handleMouseOver: (index) ->
    @setState currentIndex: index


  # Renderers
  #
  renderAddText: ->


  renderInsighters: (insights) ->
    @gatherInsighters(insights).toArray().map (insighter, index) =>
      <li key={ index } className={ cx(active: @state.currentIndex == index) } onMouseOver = { @handleMouseOver.bind(@, index) }>
        <Avatar 
          avatarURL  = { insighter.get('avatar_url') }
          value      = { insighter.get('full_name') } />
      </li>

  renderItems: (insights) ->
    insights.map (insight) -> insight.get('uuid')
    .toArray()
    .map (id, index) => 
      <li key={ id } className={ cx(active: @state.currentIndex == index) }>
        <ItemComponent key={ id } uuid={ id } cursor={ ItemComponent.getCursor(id) } />
      </li>


  render: ->
    insights = @gatherInsights()

    return null if insights.size == 0

    <section className="insight-timeline-list">
      <ul className="insighters">
        { @renderInsighters(insights) }
      </ul>
      <ul className="insight-list">
        { @renderItems(insights) }
      </ul>
    </section>     
    
