# @cjsx React.DOM

GlobalState        = require('global_state/state')

FeaturedInsights   = require('components/insight/featured')
ImportantCompanies = require('components/company/lists/important')
ImportantPinboards = require('components/pinboards/lists/important')
Greeting           = require('components/shared/greeting')
Guide              = require('components/guide')
Subscription       = require('components/shared/subscription')

# Exports
#
module.exports = React.createClass

  displayName: 'LandingApp'

  propTypes:
    isAuthorized: React.PropTypes.bool

  getDefaultProps: ->
    isAuthorized: false


  # Renderers
  #
  renderHeader: ->
    return null if @props.isProductHunt
    return null if @props.isAuthorized

    <header>
      <h1>Bite-size insights for founders</h1>
      <h2>Discover relevant insights by successful founders, investors, and experts. Create your own collections. Share with your team and the community.</h2>
    </header>


  renderFeaturedInsights: ->
    return null if @props.isProductHunt
    <FeaturedInsights />


  renderProductHuntHeader: ->
    return null unless @props.isProductHunt

    <section className="producthunt">
      <a href="/" className="close">×</a>

      <header>
        Hello Producthunters!
      </header>

      <p>
        We created CloudChart to help founders solve problems they face everyday.
        We have found valuable insights by founders, investors and experts, and
        put them toghether into relevant collections.
      </p>

      <div className="ph-logo" />

      <a href={ @props.productHuntURL } className="button">
        Open Collections
      </a>
    </section>



  renderGuide: ->
    return null #if @props.isAuthorized

    <Guide />

  renderFooter: ->
    return null #if @props.isAuthorized

    <footer>
      <a href="/auth/twitter" className="cc">Get advice</a>
    </footer>

  renderAuthorizedContent: ->
    #return null unless @props.isAuthorized

    <section className="authorized">
      <ImportantPinboards
        header = "Featured Collections"
        description = "Explore collections of successful founders, investors and experts' advices. Use them to grow your business" />

      <ImportantCompanies
        header = "Featured Companies"
        description = "Follow unicorns' timelines. Collect the insights on how they are growing" />

      <Subscription
        asBlock   = { true }
        text      = "Subscribe to our weekly email to stay in the loop: get latest insights, most helpful collections and new CloudChart features." />
    </section>


  render: ->
    <section className="landing">
      <Greeting />
      { @renderHeader() }
      { @renderFeaturedInsights() }
      { @renderProductHuntHeader() }
      { @renderAuthorizedContent() }
      { @renderFooter() }
      { @renderGuide() }
    </section>
