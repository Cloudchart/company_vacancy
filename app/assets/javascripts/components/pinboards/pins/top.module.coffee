# @cjsx React.DOM


GlobalState     = require('global_state/state')


# Stores
#
PinStore        = require('stores/pin_store')
UserStore       = require('stores/user_store.cursor')
CompanyStore    = require('stores/company_store.cursor')
PostStore       = require('stores/post_store.cursor')


# Components
#
PinsList         = require('components/pinboards/pins')
PinComponent     = require('components/pinboards/pin')


# Exports
#
module.exports = React.createClass

  displayName: 'TopInsights'

  mixins: [GlobalState.query.mixin]

  statics:

    queries:

      insights: ->
        """
          Viewer {
            top_insights {
              #{PinComponent.getQuery('pin')}
            }
          }
        """

  getInitialState: ->
    isLoaded: false


  # Helpers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('insights'))

  gatherPublishedCompaniesIds: ->
    CompanyStore
      .filter (company) -> company.get('is_published')
      .map (company) -> company.get('uuid')

  gatherInsights: ->
    publishedCompaniesIds = @gatherPublishedCompaniesIds()

    @cursor.pins
      .filter (pin) =>
        pin.get('pinnable_id') && pin.get('content') && !pin.get('parent_id') &&
        (post = PostStore.cursor.items.get(pin.get('pinnable_id'))) && 
        publishedCompaniesIds.contains(post.get('owner_id'))
      .valueSeq()
      .sort (pinA, pinB) -> 
        if pinA.get('pins_count') == pinB.get('pins_count')
          pinA.get('created_at') - pinB.get('created_at')
        else
          pinA.get('pins_count') - pinB.get('pins_count')
      .reverse()
      .take(4)
      .toArray()


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      pins: PinStore.cursor.items

    @fetch().then => @setState isLoaded: true


  # Renderers
  #
  render: ->
    return null unless @state.isLoaded

    <section className="trending-insights">
      <header>Trending Insights</header>
      <PinsList pins = { @gatherInsights() } />
    </section>
