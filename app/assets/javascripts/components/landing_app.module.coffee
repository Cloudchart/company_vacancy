# @cjsx React.DOM

GlobalState         = require('global_state/state')

UserStore           = require('stores/user_store.cursor')
CompanyStore        = require('stores/company_store.cursor')

CompanyPreview      = require('components/company/preview')
PinboardPreview     = require('components/cards/pinboard_card')
FeaturedPinboard    = require('components/landing/featured_pinboard')
ProductHuntMobile   = require('components/landing/product_hunt_mobile')


FeaturedInsights    = require('components/insight/featured')
ImportantCompanies  = require('components/company/lists/important')
ImportantPinboards  = require('components/pinboards/lists/important')
Greeting            = require('components/shared/greeting')
# Guide               = require('components/guide')
Subscription        = require('components/shared/subscription')
GuestSubscription        = require('components/shared/guest_subscription')

is_iphone           = window.matchMedia('only screen and (min-device-width: 320px) and (max-device-width: 736px)').matches

TextForSubscription = "Subscribe to our weekly email to stay in the loop: get latest insights, most helpful collections and new Insights.VC features."

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
              important_companies,
              is_authenticated
            }
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('viewer')).done =>
      @setState
        ready: true


  getDefaultProps: ->
    cursor:
      me:         UserStore.me()
      companies:  CompanyStore.cursor.items

    isAuthorized: false


  getInitialState: ->
    ready: false


  componentWillMount: ->
    @fetch()


  # Renderers
  #

  renderWelcomeBanner: ->
    return null if @props.isProductHunt

    <section className="cc-container-common banner">
      <header>
        <h1>
          Bite-size insights for&nbsp;founders
        </h1>
        <h2>
          Get valuable insights by successful founders and&nbsp;investors. Share your own.
        </h2>
      </header>
    </section>


  renderProducthuntBanner: ->
    return unless @props.isProductHunt

    <ProductHuntMobile url={ @props.productHuntURL } />


  renderFeaturedPinboard: ->
    return null if is_iphone
    <FeaturedPinboard pinboard={ @props.featured_pinboard } />


  renderPinboard: (pinboard) ->
    <div className="item" key={ pinboard.get('id') }>
      <PinboardPreview pinboard={ pinboard.get('id') } />
    </div>


  renderFeaturedPinboards: ->
    <section className="cc-container-common">
      <header>
        <h1>Featured Collections</h1>
        <h2>Collect insights. Add your own. Share with your team and the community.</h2>
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
        <h2>Follow unicorns and other startups and learn how they are growing.</h2>
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


  renderSubscription: ->
    if @props.cursor.me.get('is_authorized', false)
      <section className="cc-container-common">
        <Subscription
          text = { TextForSubscription }
        />
      </section>
    else
      <section className="cc-container-common">
        <GuestSubscription text={ TextForSubscription } />
      </section>


  render: ->
    return null unless @state.ready

    <article className="landing">
      { @renderWelcomeBanner() }
      { @renderProducthuntBanner() }
      { @renderFeaturedPinboard() }
      { @renderFeaturedPinboards() }
      { @renderFeaturedCompanies() }
      { @renderSubscription() }
    </article>
