# @cjsx React.DOM

GlobalState  = require('global_state/state')

PostStore    = require('stores/post_store.cursor')
BlockStore   = require('stores/block_store.cursor')
PictureStore = require('stores/picture_store.cursor')
PinStore     = require('stores/pin_store')

Carousel     = require('components/shared/carousel')
InsightItem  = require('components/insight/item')
PinButton    = require('components/pinnable/pin_button')

FuzzyDate    = require('utils/fuzzy_date')

# Exports
#
module.exports = React.createClass

  displayName: 'WelcomeApp'

  mixins: [GlobalState.mixin, GlobalState.query.mixin]

  statics:

    queries:

      featured: ->

        """
          Viewer {
            featured_insights {
              user,
              post {
                pins,
                blocks {
                  picture
                }
              },
              children
            }
          }
        """

  getInitialState: ->
    isLoaded: false

  fetch: (id) ->
    GlobalState.fetch(@getQuery('featured'))

  getPostBackgroundUrl: (post_id) ->
    picture_blocks = BlockStore.cursor.items.filter (block) ->
      block.get('owner_id') == post_id && 
      block.get('identity_type') == 'Picture'
    .toSeq()
    .sortBy (block) -> block.get('created_at')
    
    if picture_blocks && (picture_block = picture_blocks.first())
      PictureStore
        .findByOwner(type: 'Block', id: picture_block.get('uuid'))
        .get('url')


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      pins:    PinStore.cursor.items

    @fetch().then => @setState(isLoaded: true)


  # Renderers
  #
  renderBackgroundImage: (post_id) ->
    return null unless (postBackgroundUrl = @getPostBackgroundUrl(post_id))

    <img className="background" src={ postBackgroundUrl } />

  renderPosts: ->
    @cursor.pins
      .filter (pin) -> pin.get('is_featured')
      .map (pin, index) =>
        post = PostStore.cursor.items.filter (post) ->
          post.get('uuid') == pin.get('pinnable_id')
        .first()

        formatted_date = FuzzyDate.format(post.get('effective_from'), post.get('effective_till'))

        <article 
          className = "featured-post-preview"
          key       = { index } >
          { @renderBackgroundImage(post.get('uuid')) }
          <div className="wrapper">
            <header>
              <h1><span>{ post.get('title') }</span></h1>
              <div className="info">
                <ul className="round-buttons">
                  <PinButton 
                    title         = { post.get('title') }
                    pinnable_id   = { post.get('uuid') }
                    pinnable_type = "Post" />
                </ul>
                <div className="date">{ formatted_date }</div>
              </div>
              <div className="spacer"></div>
              <h2>Breaking news</h2>
            </header>
            <div>
              <InsightItem cursor = { InsightItem.getCursor(pin.get('uuid')) } />
            </div>
          </div>
        </article>
      .toArray()


  render: ->
    return null unless @state.isLoaded

    <Carousel>
      { @renderPosts() }
    </Carousel>
    
    