# @cjsx React.DOM

GlobalState      = require('global_state/state')

FeaturedInsights = require('components/insight/featured')
RecentCompanies  = require('components/company/lists/recent')
TopInsights      = require('components/pinboards/pins/top')
Greeting         = require('components/shared/greeting')
Guide            = require('components/guide')
Subscription     = require('components/shared/subscription')

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
      <h1>Learn from Unicorns</h1>
      <h2>Discover how successfull startups are growing</h2>
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
      <TopInsights />
      <RecentCompanies />
      <Subscription 
        asBlock   = { true }
        text      = "Subscribe to our weekly email: we'll keep you posted on new unicorns' timelines, useful insights and new CloudChart features." />
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