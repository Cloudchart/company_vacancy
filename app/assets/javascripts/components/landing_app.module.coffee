# @cjsx React.DOM

GlobalState      = require('global_state/state')

FeaturedInsights = require('components/insight/featured')
RecentCompanies  = require('components/company/lists/recent')
TopInsights      = require('components/pinboards/pins/top')
Greeting         = require('components/shared/greeting')
Guide            = require('components/guide')

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

  renderTopInsights: ->
    return null unless @props.isAuthorized

    <TopInsights />

  renderRecentCompanies: ->
    return null unless @props.isAuthorized

    <RecentCompanies />


  render: ->
    <section className="landing">
      <Greeting />
      { @renderHeader() }
      <FeaturedInsights />
      { @renderTopInsights() }
      { @renderRecentCompanies() }
      { @renderFooter() }
      { @renderGuide() }
    </section>