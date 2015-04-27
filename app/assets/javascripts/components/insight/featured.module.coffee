# @cjsx React.DOM

GlobalState  = require('global_state/state')

FeatureStore = require('stores/feature_store')
PostStore    = require('stores/post_store.cursor')
PinStore     = require('stores/pin_store')

Carousel     = require('components/shared/carousel')
InsightItem  = require('components/insight/item')
PinButton    = require('components/pinnable/pin_button')

FuzzyDate    = require('utils/fuzzy_date')

ModalStackCursor  = GlobalState.cursor(['meta', 'modal', 'stack'])

# Exports
#
module.exports = React.createClass

  displayName: 'FeaturedInsights'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      featured: ->

        """
          Viewer {
            insight_features {
              insight {
                user,
                post {
                  company,
                  pins
                },
                children
              }
            }
          }
        """

  getDefaultProps: ->
    cursor: ModalStackCursor

  getInitialState: ->
    isLoaded: false

  fetch: (id) ->
    GlobalState.fetch(@getQuery('featured'))


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      features: FeatureStore.cursor.items

    @fetch().then => @setState(isLoaded: true)


  # Renderers
  #
  renderBackgroundImage: (feature) ->
    return null unless (postBackgroundUrl = feature.get('assigned_image_url'))

    <img className="background" src={ postBackgroundUrl } />

  renderPosts: ->
    @cursor.features
      .sortBy (feature) -> - +feature.get('created_at')
      .map (feature, index) =>
        pin = PinStore.cursor.items.filter (pin) ->
          pin.get('uuid') == feature.get('featurable_id')
        .first()

        post = PostStore.cursor.items.filter (post) ->
          post.get('uuid') == pin.get('pinnable_id')
        .first()

        return null unless post && feature

        formatted_date = FuzzyDate.format(post.get('effective_from'), post.get('effective_till'))

        <article 
          className = "featured-post-preview"
          key       = { index } >
          { @renderBackgroundImage(feature) }
          <div className="wrapper">
            <a className="for-group" href={ feature.get('assigned_url') }>
              <header>
                <h1><span>{ feature.get('assigned_title') }</span></h1>
                <div className="info">
                  <ul className="round-buttons">
                    <PinButton 
                      title         = { feature.get('title') }
                      pinnable_id   = { post.get('uuid') }
                      pinnable_type = "Post" />
                  </ul>
                  <div className="date">{ formatted_date }</div>
                </div>
                <div className="spacer"></div>
                <h2> { feature.get('category') } </h2>
              </header>
            </a>
            <div>
              <InsightItem cursor = { InsightItem.getCursor(pin.get('uuid')) } uuid = { pin.get('uuid') } />
            </div> 
          </div>
        </article>
      .toArray()


  render: ->
    return null unless @state.isLoaded

    <Carousel 
      className         = "featured-insights"
      withSlideshow     = { true }
      isSlideshowPaused = { !!ModalStackCursor.deref(Immutable.List()).size } >
      { @renderPosts() }
    </Carousel>
    
    