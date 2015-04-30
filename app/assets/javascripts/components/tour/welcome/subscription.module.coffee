# @cjsx React.DOM

UserSyncApi    = require('sync/user_sync_api')

ModalStack     = require('components/modal_stack')

StandardButton = require('components/form/buttons').StandardButton
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
  finishTour: ->
    UserSyncApi.deleteTempInfoBlock(@props.user, type: "welcome_tour").then =>
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
        <h2>Add your email to profile: we'll keep you posted on new unicorns' timelines, useful insights, and new CloudChart features.</h2>
      </header>
      <div className="equation">
        <i className="svg-icon svg-cloudchart-logo" />
        +
        <i className="fa fa-envelope-o" />
        =
        <i className="fa fa-heart" />
      </div>
      <Subscription 
        buttonText         = "Sign me up!"
        subscribedText     = "Great news: you have already subscribed, we'll be in touch!"
        onSubscriptionDone = { @finishTour } />
    </article>
