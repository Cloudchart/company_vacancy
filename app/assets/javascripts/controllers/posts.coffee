populateStores = (data, callback) ->
  Dispatcher = require('dispatcher/dispatcher')
  GlobalState = require('global_state/state')

  PostStore = require('stores/post_store')
  BlockStore = require('stores/block_store')
  PersonStore = require('stores/person')
  CompanyStore = require('stores/company')
  PictureStore = require('stores/picture_store')
  ParagraphStore = require('stores/paragraph_store')
  VisibilityStore = require('stores/visibility_store')


  # Fetch company with dependencies
  #
  require('sync/company').fetch(data.company_id).done (json) ->

    Dispatcher.handleServerAction
      type: 'company:fetch:done'
      data: [data.company_id, json]

    _.each json.people, (person) -> PersonStore.add(person.uuid, person)

    CompanyStore.add(json.company.uuid, json.company)
    CompanyStore.emitChange()

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

    callback() if callback

    PostStore.emitChange()

    Dispatcher.handleServerAction
      type: 'post:fetch-all:done'
      data: [json]


@['posts#show'] = (data) ->
  populateStores data, ->
    Post = require('components/post')

    React.renderComponent(
      Post({ id: data.id, company_id: data.company_id, cursor: Post.getCursor(data.company_id) }), document.querySelector('body > main')
    )
