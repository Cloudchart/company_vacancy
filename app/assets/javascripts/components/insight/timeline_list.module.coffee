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

  propTypes:
    postUrl: React.PropTypes.string.isRequired

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

  gatherInsightsForPreview: ->
    @gatherInsights().take(3)

  gatherInsighters: (insights) ->
    insights
      .map (insight) -> insight.get('user_id')
      .map (user_id) -> UserStore.get(user_id)

  getMoreNumber: ->
    (@gatherInsights().size || 0) - (@gatherInsightsForPreview().size || 0)


  # Handlers
  #
  handleMouseEnter: (index) ->
    @setState currentIndex: index


  # Renderers
  #
  renderMoreText: ->
    return null unless ((count = @getMoreNumber()) > 0)

    <li className="more">
      <a href = { @props.postUrl } >
        + { count } more
      </a>
    </li>

  renderInsighterGroup: (insighters) ->
    insighters.map (insighter, index) =>
      <article 
        key={ index }
        className={ cx(active: @state.currentIndex == index) }
        onMouseEnter = { @handleMouseEnter.bind(@, index) }>
        <Avatar 
          avatarURL  = { insighter.get('avatar_url') }
          value      = { insighter.get('full_name') } />
      </article>
    .toArray()

  renderInsighters: (insights) ->
    return null unless (insighters = @gatherInsighters(insights)).size > 1

    insighters.valueSeq().toMap()
      .groupBy (insighter) -> insighter.get('uuid')
      .map (insighters, index) =>
        <li key={ index }>
          { @renderInsighterGroup(insighters) }
        </li>
      .toArray()

  renderItems: (insights) ->
    insights.map (insight) -> insight.get('uuid')
    .toArray()
    .map (id, index) => 
      <li key={ id } className={ cx(active: @state.currentIndex == index) }>
        <ItemComponent key={ id } uuid={ id } cursor={ ItemComponent.getCursor(id) } />
      </li>


  render: ->
    insights = @gatherInsightsForPreview()

    return null if insights.size == 0

    <section className="insight-timeline-list">
      <ul className="insighters">
        { @renderInsighters(insights) }
        { @renderMoreText() }
      </ul>
      <ul className="insight-list">
        { @renderItems(insights) }
      </ul>
    </section>     
    
