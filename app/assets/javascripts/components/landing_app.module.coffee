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
    return null if @props.isAuthorized

    <header>
      <h1>Bite-size advice for founders</h1>
      <h2>When in doubt, use CloudChart.</h2>
    </header>

  renderGuide: ->
    return null if @props.isAuthorized

    <Guide />

  renderFooter: ->
    return null if @props.isAuthorized

    <footer>
      <a href="/auth/twitter" className="cc">Start Learning</a>
    </footer>

  renderAuthorizedContent: ->
    return null unless @props.isAuthorized

    <section className="authorized">
      <p className="cloud-columns cloud-columns-flex">
        Cloudchart is an educational tool for the next generation of founders. Just like your business, CloudChart evolves everyday, providing you with fresh learning material: new insights and unicorn companies' updates.
      </p>
      <section className="featured-collections">
        <header className="cloud-columns cloud-columns-flex">Featured Collections</header>
        <p className="cloud-columns cloud-columns-flex">Explore collections of successful founders, investors and experts advices. Use them to grow your business</p>
        <ImportantPinboards />
      </section>
      <section className="featured-companies">
        <header className="cloud-columns cloud-columns-flex">Featured Companies</header>
        <p className="cloud-columns cloud-columns-flex">Follow unicorns' timelines. Collect the insights on how they are growing</p>
        <ImportantCompanies />
      </section>
      <Subscription
        asBlock   = { true }
        text      = "Join our weekly mailing list to get updates on new helpful advices, unicorn timelines and upcoming CloudChart features." />
    </section>


  render: ->
    <section className="landing">
      <Greeting />
      { @renderHeader() }
      <FeaturedInsights />
      { @renderAuthorizedContent() }
      { @renderFooter() }
      { @renderGuide() }
    </section>