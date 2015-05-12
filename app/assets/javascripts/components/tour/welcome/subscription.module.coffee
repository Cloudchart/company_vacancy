# @cjsx React.DOM

TokenStore     = require('stores/token_store.cursor')
UserStore      = require('stores/user_store.cursor')

ModalStack     = require('components/modal_stack')
StandardButton = require('components/form/buttons').StandardButton
SyncButton     = require("components/form/buttons").SyncButton
Subscription   = require('components/shared/subscription')

# Exports
#
module.exports = React.createClass

  displayName: 'WelcomeTourSubscription'

  propTypes:
    className: React.PropTypes.string
    onNext:    React.PropTypes.func


  # Helpers
  #
  getWelcomeTour: ->
    TokenStore.findByUserAndName(UserStore.me(), 'welcome_tour')

  finishTour: ->
    if @getWelcomeTour()
      TokenStore.destroyInsightTour(@getWelcomeTour().get('uuid')).then -> ModalStack.hide()
    else
      ModalStack.hide()


  # Renderers
  #
  render: ->
    <article className={ "tour-subscription " + @props.className }>
      <StandardButton 
        className = "close transparent"
        iconClass = "cc-icon cc-times"
        onClick   = { @finishTour }/>
      <header>
        <div className="logo">
          <i className="svg-icon svg-cloudchart-logo"></i>
          Cloud<b>Chart</b>
        </div>
        <h1>Stay in the loop</h1>
        <h2>Sign up for our weekly mailing list: we'll keep you posted on new unicorns' timelines, useful insights, and new CloudChart features.</h2>
      </header>
      <div className="equation">
        <i className="svg-icon svg-cloudchart-logo" />
        +
        <i className="fa fa-envelope-o" />
        =
        <i className="fa fa-heart" />
      </div>
      <Subscription buttonText = "Sign me up!" onSubscriptionDone = { @finishTour }>
        <p>Great news: you have already subscribed, we'll be in touch!</p>
        <SyncButton
          className = "cc"
          onClick   = { @finishTour }
          text      = "Got This!"
          type      = "button" />
      </Subscription>
    </article>
