# @cjsx React.DOM

GlobalState       = require('global_state/state')

UserStore         = require('stores/user_store.cursor')

TourIntroduction  = require('components/tour/introduction')
TourCompanies     = require('components/tour/companies')
TourTimeline      = require('components/tour/timeline')
TourSubscription  = require('components/tour/subscription')

NavigatorMixin    = require('components/mixins/navigator')

# Exports
#
module.exports = React.createClass

  displayName: 'TourApp'

  mixins: [NavigatorMixin, GlobalState.query.mixin]

  statics:
    queries:
      tour: ->
        """
          Viewer {
            #{TourCompanies.getQuery('companies')}
          }
        """ 

  fetch: ->
    GlobalState.fetch(@getQuery('tour'))

  getInitialState: ->
    isLoaded: false


  # Helpers
  #
  isLoaded: ->
    @state.isLoaded

  getPositionsNumber: ->
    5


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor = UserStore.me()

    unless @isLoaded()
      @fetch().then => @setState isLoaded: true


  # Renderers
  #
  renderIntroduction: ->
    <TourIntroduction
      active = { @state.position == 0 }
      onNext = { @goToNext }
      user   = { @cursor } />

  renderCompanies: ->
    <TourCompanies
      active = { @state.position == 1 }
      onNext = { @goToNext } />

  renderTimeline: ->
    <TourTimeline
      active           = { @state.position == 2 || @state.position == 3 }
      isInsightFocused = { @state.position == 3 } />

  renderSubscription: ->
    <TourSubscription
      active = { @state.position == 4 }
      user   = { @cursor } />


  render: ->
    return null unless @isLoaded()

    <section className="tour navigator">
      <section className="tour-wrapper">
        { @renderIntroduction() }
        { @renderCompanies() }
        { @renderTimeline() }
        { @renderSubscription() }
      </section>
      { @renderPrevButton() }
      { @renderNextButton() }
      { @renderNavigation() }
    </section>