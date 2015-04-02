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

      post: ->

        """
          Post {
            pins {
              user,
              children
            },
            blocks {
              picture
            }
          }
        """

  getInitialState: ->
    isLoaded: false

  fetch: (id) ->
    GlobalState.fetch(@getQuery('post'), id: id)

  getPostBackgroundUrl: (post_id) ->
    block = BlockStore.cursor.items.filter (block) ->
      block.get('owner_id') == post_id && 
      block.get('identity_type') == 'Picture'
    .toSeq()
    .sortBy (block) -> block.get('created_at')
    .first()

    PictureStore
      .findByOwner(type: 'Block', id: block.get('uuid'))
      .get('url')


  # Lifecycle methods
  #
  componentWillMount: ->
    @cursor =
      posts:    PostStore.cursor.items

    Promise.all([
      @fetch("aa27f02c-b4df-44fb-9fa1-96c46f80971d"),
      @fetch("93d78ee7-a3e5-4d44-a96f-f12f69709f07")
    ]).then =>
      @setState(isLoaded: true)



  # Renderers
  #
  renderPosts: ->
    @cursor.posts.map (post, index) =>
      formatted_date = FuzzyDate.format(post.get('effective_from'), post.get('effective_till'))
      postBackgroundUrl = @getPostBackgroundUrl(post.get('uuid'))
      insightId = PinStore.filterInsightsForPost(post.get('uuid')).first().get('uuid')

      <article 
        className = "featured-post-preview"
        key       = { index } >
        <img className="background" src={ postBackgroundUrl } />
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
            <h2>Breaking news</h2>
          </header>
          <InsightItem cursor = { InsightItem.getCursor(insightId) } />
        </div>
      </article>
    .toArray()


  render: ->
    return null unless @state.isLoaded

    <Carousel>
      { @renderPosts() }
    </Carousel>
    
    