# @cjsx React.DOM

GlobalState         = require('global_state/state')

UserStore           = require('stores/user_store.cursor')
CompanyStore        = require('stores/company_store.cursor')
FeatureStore        = require('stores/feature_store')
PinboardStore       = require('stores/pinboard_store')

CompanyPreview      = require('components/company/preview')
PinboardPreview     = require('components/cards/pinboard_card')
FeaturedPinboard    = require('components/landing/featured_pinboard')
ProductHuntMobile   = require('components/landing/product_hunt_mobile')

Greeting            = require('components/shared/greeting')
GuestSubscription   = require('components/shared/guest_subscription')
MainBanner          = require('components/welcome/main_banner')

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
            main_features {
              featurable_pinboard {
                #{PinboardPreview.getQuery('pinboard')}
              },
              featurable_company {
                #{CompanyPreview.getQuery('company')}
              }
            },
            edges {
              is_authenticated
            }
          }
        """


  fetch: ->
    GlobalState.fetch(@getQuery('viewer')).done (json) =>
      @setState
        main_features_ids: json.query.main_features.ids || []
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


  # Helpers
  #
  getFeatureForPinboard: ->
    @getFeaturesForPinboards()
      .filter (feature) -> feature.get('position') == -1
      .first()

  getFeaturesForPinboards: ->
    Immutable.Seq(@state.main_features_ids.map (id) -> FeatureStore.get(id))
      .filter (feature) -> feature.get('featurable_type') == 'Pinboard'
      .sortBy (feature) -> feature.get('position')

  getFeaturesForCompanies: ->
    Immutable.Seq(@state.main_features_ids.map (id) -> FeatureStore.get(id))
      .filter (feature) -> feature.get('featurable_type') == 'Company'
      .sortBy (feature) -> feature.get('position')


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
    return null unless featureForPinboard = @getFeatureForPinboard()
    <FeaturedPinboard pinboard={ featureForPinboard.get('featurable_id') } scope='main' />


  renderPinboard: (pinboard) ->
    <div className="item" key={ pinboard.get('id') }>
      <PinboardPreview pinboard={ pinboard.get('id') } />
    </div>


  renderFeaturedPinboards: ->
    featuresForPinboards = @getFeaturesForPinboards()
    return null if featuresForPinboards.size == 0

    <section className="cc-container-common">
      <header>
        <h1>{ "Featured Collections" }</h1>
        <h2>{ "Collect insights. Add your own. Share with your team and the community." }</h2>
      </header>

      <section className="flow">
        {
          featuresForPinboards
            .filter (feature) -> feature.get('position') >= 0
            .map (feature) => @renderPinboard(PinboardStore.get(feature.get('featurable_id')))
            .toArray()
        }
      </section>
    </section>


  renderCompany: (company) ->
    <div className="item" key={ company.get('id') }>
      <CompanyPreview uuid={ company.get('id') } />
    </div>


  renderFeaturedCompanies: ->
    featuresForCompanies = @getFeaturesForCompanies()
    return null if featuresForCompanies.size == 0

    <section className="cc-container-common">
      <header>
        <h1>{ "Featured Companies" }</h1>
        <h2>{ "Follow unicorns and other startups and learn how they are growing." }</h2>
      </header>

      <section className="flow">
        {
          featuresForCompanies
            .map (feature) => @renderCompany(CompanyStore.get(feature.get('featurable_id')))
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
