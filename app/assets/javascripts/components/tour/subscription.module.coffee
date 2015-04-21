# @cjsx React.DOM


UserSyncApi  = require('sync/user_sync_api')

ModalStack   = require('components/modal_stack')

SyncButton   = require("components/form/buttons").SyncButton

cx           = React.addons.classSet

# Exports
#
module.exports = React.createClass

  displayName: 'TourSubscription'

  propTypes:
    onNext: React.PropTypes.func

  getInitialState: ->
    isSyncing: false


  getClassName: ->
    cx(
      "slide tour-subscription": true
      active: @props.active
    )

  finishTour: ->
    @setState isSyncing: true

    UserSyncApi.finishTour().then =>
      ModalStack.hide()

  render: ->
    <article className={ @getClassName() }>>
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
      <input className="" placeholder={ @props.user.get('first_name') + ", your work email goes here" } />
      <SyncButton
        className = "cc"
        isSyncing = { @state.isSyncing }
        onClick   = { @finishTour }
        text      = "Sign me up!" />
    </article>