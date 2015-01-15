@['posts#index'] = (data) ->
  PostStore = require('stores/post_store')
  BlockStore = require('stores/block_store')
  PictureStore = require('stores/picture_store')
  ParagraphStore = require('stores/paragraph_store')
  VisibilityStore = require('stores/visibility_store')

  # Fetch all posts with dependencies
  # 
  require('sync/post_sync_api').fetchAll(data.company_id).done (json) ->
    _.each {
      posts: PostStore
      blocks: BlockStore
      pictures: PictureStore
      paragraphs: ParagraphStore
      visibilities: VisibilityStore
    }, (store, key) ->
      _.each json[key], (item) -> store.add(item.uuid, item)

    PostStore.emitChange()

  # Mount posts
  # 
  Posts = require('components/posts_app')
  React.renderComponent(Posts({ company_id: data.company_id, story_id: data.story_id }), document.querySelector('body > main'))
