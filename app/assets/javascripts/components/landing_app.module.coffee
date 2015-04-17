# @cjsx React.DOM

GlobalState      = require('global_state/state')

FeaturedInsights = require('components/insight/featured')
RecentCompanies  = require('components/company/lists/recent')
TopInsights      = require('components/pinboards/pins/top')

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
      <h2>Discover how successfull startups have grown</h2>
    </header>

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
      { @renderHeader() }
      <FeaturedInsights />
      { @renderTopInsights() }
      { @renderRecentCompanies() }
      { @renderFooter() }
    </section>