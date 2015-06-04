# @cjsx React.DOM

GlobalState        = require('global_state/state')

FeaturedInsights   = require('components/insight/featured')
RecentCompanies    = require('components/company/lists/recent')
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
      <section className="featured-insights">
        <header>Featured Collections</header>
        <ImportantPinboards />
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