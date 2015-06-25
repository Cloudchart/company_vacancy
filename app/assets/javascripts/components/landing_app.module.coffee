# @cjsx React.DOM

GlobalState       = require('global_state/state')

UserStore         = require('stores/user_store.cursor')
CompanyStore      = require('stores/company_store.cursor')

CompanyPreview    = require('components/company/preview')
PinboardPreview   = require('components/pinboards/pinboard')
FeaturedPinboard  = require('components/landing/featured_pinboard')


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

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:
    queries:
      viewer: ->
        """
          Viewer {
            important_pinboards {
              #{PinboardPreview.getQuery('pinboard')}
            },
            important_companies {
              #{CompanyPreview.getQuery('company')}
            },
            edges {
              important_pinboards,
              important_companies
            }
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('viewer'))


  getDefaultProps: ->
    cursor:
      me:         UserStore.me()
      companies:  CompanyStore.cursor.items

    isAuthorized: false


  componentWillMount: ->
    @fetch()


  # Renderers
  #
  renderFeaturedPinboard: ->
    <FeaturedPinboard pinboard={ @props.featured_pinboard } />


  renderPinboard: (pinboard) ->
    <div className="item" key={ pinboard.get('id') }>
      <PinboardPreview uuid={ pinboard.get('id') } />
    </div>


  renderFeaturedPinboards: ->
    <section className="cc-container-common">
      <header>
        <h1>Featured Collections</h1>
        <h2>Collect insights. Create your own collections. Share with your team and the community.</h2>
      </header>

      <section className="flow">
        {
          @props.cursor.me.get('important_pinboards', Immutable.Seq())
            .sortBy (c) -> c.get('title')
            .map @renderPinboard
            .toArray()
        }
      </section>
    </section>


  renderCompany: (company) ->
    <div className="item" key={ company.get('id') }>
      <CompanyPreview uuid={ company.get('id') } />
    </div>


  renderFeaturedCompanies: ->
    <section className="cc-container-common">
      <header>
        <h1>Featured Companies</h1>
        <h2>Follow unicorns and learn how they are growing.</h2>
      </header>

      <section className="flow">
        {
          @props.cursor.me.get('important_companies', Immutable.Seq())
            .sortBy (c) -> c.get('name')
            .map @renderCompany
            .toArray()
        }
      </section>
    </section>


  render: ->
    <article className="landing">
      { @renderFeaturedPinboard() }
      { @renderFeaturedPinboards() }
      { @renderFeaturedCompanies() }
    </article>
