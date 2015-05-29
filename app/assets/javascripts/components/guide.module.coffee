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

  displayName: 'Guide'

  propTypes:
    isAuthorized: React.PropTypes.bool

  getDefaultProps: ->
    isAuthorized: false

  renderInsight: ->
    <article className="insight item">
      <header>
        <div className="human shervin-pishevar">
          <figure className="avatar"></figure>
          <section className="credentials">
            <p className="name">
              <span>
                <span>Shervin </span>
                <span className="last-part">
                  <span>Pishevar</span>
                  <i className="svg-icon svg-unicorn"></i>
                </span>
              </span>
            </p>
            <p className="occupation">Co-Founder and Managing Partner, SherpaVentures</p>
          </section>
        </div>
        <ul className="round-buttons">
          <li className="active">
            <i className="fa fa-thumb-tack"></i>
          </li>
        </ul>
      </header>
      <section className="content">
        <span>Surround yourself with value creators so you can be open with your heart and mind in an environment based on grace, merit and generosity.</span>
        { " " }
        <a className="origin" target="_blank" href="https://twitter.com/shervin/status/300671129960452096">
          <i className="fa fa-code"></i>
        </a>
      </section>
    </article>

  renderTeslaPreview: ->
    <article className="company-preview cloud-card tesla">
      <a className="company-preview-link for-group">
        <header>
          <figure className="logo"></figure>
          <h1>Tesla Motors</h1>
        </header>
        <div className="info">
          <ul className="stats">
            <li>11 insights</li>
            <li>50 posts</li>
          </ul>
        </div>
        <p className="description">American company that designs, manufactures, and sells electric cars and electric vehicle powertrain components</p>
        <footer>
          <section className="people">
            <div className="human elon-musk">
              <figure className="avatar"></figure>
              <section className="credentials">
                <p className="name">Elon Musk</p>
              </section>
            </div>
          </section>
        </footer>
      </a>
    </article>

  renderOpswarePreview: ->
    <article className="company-preview cloud-card opsware">
      <a className="company-preview-link for-group">
        <header>
          <figure className="logo"></figure>
          <h1>Opsware</h1>
        </header>
        <div className="info">
          <ul className="stats">
            <li>12 insights</li>
            <li>55 posts</li>
          </ul>
        </div>
        <p className="description">A software company providing cloud computing services</p>
        <footer>
          <section className="people ben-horowitz">
            <div className="human">
              <figure className="avatar"></figure>
              <section className="credentials">
                <p className="name">Ben Horowitz</p>
              </section>
            </div>
            <div className="human tim-howes">
              <figure className="avatar"></figure>
              <section className="credentials">
                <p className="name">Tim Howes</p>
              </section>
            </div>
          </section>
        </footer>
      </a>
    </article>


  render: ->
    <section className="guide">
      <section>
        <header>A tool for the next generation of founders.</header>
        <p>Just like your business, CloudChart evolves everyday, providing you with fresh learning material: <strong>new insights</strong> and unicorn companies' updates.</p>
        <section className="insight-guide">
          <p>Learn how to grow your own company using <strong>actionable insights</strong> by successful founders, investors, and experts.</p>
          { @renderInsight() }
        </section>
      </section>
      <section>
        <header>Follow companies you’re interested in.</header>
        <p>Get their updates and learn from their successes and failures in real time.</p>
        <section className="companies-list cloud-columns cloud-columns-flex">
          <section className="cloud-column">
            { @renderTeslaPreview() }
          </section>
          <section className="cloud-column">
            { @renderOpswarePreview() }
          </section>
        </section>
      </section>
      <footer>
        <a href="/auth/twitter" className="cc">Start Learning</a>
      </footer>
    </section>