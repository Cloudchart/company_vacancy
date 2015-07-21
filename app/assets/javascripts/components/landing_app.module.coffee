# @cjsx React.DOM

GlobalState         = require('global_state/state')

UserStore           = require('stores/user_store.cursor')
CompanyStore        = require('stores/company_store.cursor')

CompanyPreview      = require('components/company/preview')
PinboardPreview     = require('components/cards/pinboard_card')
FeaturedPinboard    = require('components/landing/featured_pinboard')
ProductHuntMobile   = require('components/landing/product_hunt_mobile')

FeaturedInsights    = require('components/insight/featured')
Greeting            = require('components/shared/greeting')
GuestSubscription   = require('components/shared/guest_subscription')
MainBanner          = require('components/welcome/main_banner')

device              = require('utils/device')

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
            featured_pinboards {
              #{PinboardPreview.getQuery('pinboard')}
            },
            featured_companies {
              #{CompanyPreview.getQuery('company')}
            },
            edges {
              featured_pinboards,
              featured_companies,
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
    shouldDisplay = !(
      @props.cursor.me.get('is_authenticated', false) ||
      @props.isProductHunt
    )

    <MainBanner shouldDisplay = { shouldDisplay } />


  renderProducthuntBanner: ->
    return unless @props.isProductHunt

    <ProductHuntMobile url={ @props.productHuntURL } />


  renderFeaturedPinboard: ->
    return null if device.is_iphone
    return null unless featured_pinboard = @props.cursor.me.get('featured_pinboards')
      .filter (pinboard) -> pinboard.get('featured_position') == 0
      .first()

    <FeaturedPinboard pinboard={ featured_pinboard.get('id') } />


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
          @props.cursor.me.get('featured_pinboards', Immutable.Seq())
            .filter (pinboard) -> pinboard.get('featured_position') > 0
            .sortBy (pinboard) -> pinboard.get('featured_position')
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
          @props.cursor.me.get('featured_companies', Immutable.Seq())
            .sortBy (company) -> company.get('featured_position')
            .map @renderCompany
            .toArray()
        }
      </section>
    </section>


  renderSubscription: ->
    return null if @props.cursor.me.get('is_authenticated', false)

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
