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

  propTypes:
    filterPinned: React.PropTypes.bool

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

  getDefaultProps: ->
    filterPinned: false

  getInitialState: ->
    isLoaded: false


  # Helpers
  #
  fetch: ->
    GlobalState.fetch(@getQuery('insights'))

  isLoaded: ->
    @state.isLoaded && @cursor.user.deref(false)

  gatherPublishedCompaniesIds: ->
    CompanyStore
      .filter (company) -> company.get('is_published')
      .map (company) -> company.get('uuid')

  gatherInsights: ->
    publishedCompaniesIds = @gatherPublishedCompaniesIds()
    pinnedIds = PinStore.filterRepinsForUser(@cursor.user.get('uuid')).map (pin) -> pin.get('parent_id')

    @cursor.pins
      .filter (pin) =>
        pin.get('pinnable_id') && pin.get('content') && !pin.get('parent_id') &&
        (post = PostStore.cursor.items.get(pin.get('pinnable_id'))) && 
        publishedCompaniesIds.contains(post.get('owner_id')) &&
        (!@props.filterPinned || !pinnedIds.contains(pin.get('uuid')))
      .valueSeq()
      .sort (pinA, pinB) -> 
        if pinA.get('weight') == pinB.get('weight')
          pinA.get('created_at') - pinB.get('created_at')
        else
          pinA.get('weight') - pinB.get('weight')
      .reverse()
      .take(4)
      .toArray()


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      user: UserStore.me()
      pins: PinStore.cursor.items

    @fetch().then => @setState isLoaded: true


  # Renderers
  #
  render: ->
    return null unless @isLoaded()

    <PinsList pins = { @gatherInsights() } />
