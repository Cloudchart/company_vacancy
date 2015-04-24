# @cjsx React.DOM

GlobalState       = require('global_state/state')

UserStore         = require('stores/user_store.cursor')

TourIntroduction  = require('components/tour/welcome/introduction')
TourCompanies     = require('components/tour/welcome/companies')
TourTimeline      = require('components/tour/welcome/timeline')
TourSubscription  = require('components/tour/welcome/subscription')

NavigatorMixin    = require('components/mixins/navigator')

# Exports
#
module.exports = React.createClass

  displayName: 'WelcomeTourApp'

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


  # Handlers
  #
  handleNavigationButtons: (event) ->
    @goToPrev() if event.keyCode == 37
    @goToNext() if event.keyCode == 39


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor = UserStore.me()

    unless @isLoaded()
      @fetch().then => @setState isLoaded: true

  componentDidMount: ->
    window.addEventListener('keydown', @handleNavigationButtons)

  componentWillUnmount: ->
    window.removeEventListener('keydown', @handleNavigationButtons)


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