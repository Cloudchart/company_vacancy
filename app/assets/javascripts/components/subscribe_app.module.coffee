# @cjsx React.DOM

# Imports
# 
Constants = require('constants')

MainBanner = require('components/welcome/main_banner')
Subscription = require('components/shared/subscription')
GuestSubscription = require('components/shared/guest_subscription')


# Utils
#
# cx = React.addons.classSet
SubscribeBenefits = [
  "Be the first to know about our new features and how you can use them",
  "Get our curated #insighthunt newsletter with top rated insights",
  "Follow our exciting story of building and growing #{Constants.SITE_NAME}",
  "No spam, that's a promise!"
]


# Main component
# 
module.exports = React.createClass

  displayName: 'SubscribeApp'
  propTypes:
    isUserAuthenticated: React.PropTypes.bool.isRequired
  # mixins: []
  # statics: {}


  # Component Specifications
  # 
  # getDefaultProps: ->
  # getInitialState: ->


  # Lifecycle Methods
  # 
  # componentWillMount: ->
  # componentDidMount: ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->


  # Fetchers
  #
  # fetch: ->


  # Helpers
  # 
  # getSomething: ->


  # Handlers
  # 
  # handleThingClick: (event) ->


  # Renderers
  # 
  renderSubscribeBenefits: ->
    <ul>
      {
        SubscribeBenefits.map (value, index) ->
          <li key = { index }>
            <i className="fa fa-chevron-right"></i>
            <span>{ value }</span>
          </li>
      }
    </ul>

  renderSubscription: ->
    if @props.isUserAuthenticated
      <Subscription displaySubscribedMessage = true />
    else
      <GuestSubscription is_subscribed = false />


  # Main render
  # 
  render: ->
    <article className="subscribe">
      <MainBanner/>

      <section className="cc-container-common">
        <section className="benefits">
          <section className="container">
            <h1>Subscribe to our awesome email</h1>
            { @renderSubscribeBenefits() }
          </section>
        </section>
      </section>

      <section className="cc-container-common">
        { @renderSubscription() }
      </section>

    </article>
