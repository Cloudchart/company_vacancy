# @cjsx React.DOM

GlobalState       = require('global_state/state')

UserStore         = require('stores/user_store.cursor')

TourIntroduction  = require('components/tour/welcome/introduction')
TourCompanies     = require('components/tour/welcome/companies')
TourTimeline      = require('components/tour/welcome/timeline')
TourSubscription  = require('components/tour/welcome/subscription')

NavigatorMixin    = require('components/mixins/navigator')

cx = React.addons.classSet

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

  getSlideClass: (indexes...) ->
    cx(
      active:            indexes.indexOf(@state.position) != -1
      slide:             true
      "with-transition": @state.isNexted
    )


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
      className = { @getSlideClass(0) }
      onNext    = { @goToNext }
      user      = { @cursor } />

  renderCompanies: ->
    <TourCompanies 
      className = { @getSlideClass(1) }
      onNext    = { @goToNext } />

  renderTimeline: ->
    <TourTimeline 
      active           = { [2, 3].indexOf(@state.position) != -1 }
      className        = { @getSlideClass(2, 3) }
      isInsightFocused = { @state.position == 3 }
      isAnimated       = { @state.isNexted } />

  renderSubscription: ->
    <TourSubscription
      className = { @getSlideClass(4) }
      user     = { @cursor } />


  render: ->
    return null unless @isLoaded()

    <section className="tour welcome-tour navigator">
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