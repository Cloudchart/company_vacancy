Dispatcher = require('dispatcher/dispatcher')

# Show
#
@['companies#show'] = (data) ->

  CompanyStore    = require('stores/company')
  PostStore       = require('stores/post_store')
  BlockStore      = require('stores/block_store')
  PictureStore    = require('stores/picture_store')
  ParagraphStore  = require('stores/paragraph_store')
  PersonStore     = require('stores/person')
  VacancyStore    = require('stores/vacancy')
  RoleStore       = require('stores/role_store')
  TokenStore      = require('stores/token_store')
  UserStore       = require('stores/user_store')
  CursorUserStore = require('stores/user_store.cursor')
  TagStore        = require('stores/tag_store')
  VisibilityStore = require('stores/visibility_store')
  StoryStore      = require('stores/story_store')
  PinStore        = require('stores/pin_store')
  GlobalState     = require('global_state/state')

  # Mount company
  #
  Company = require('components/company_app')
  React.renderComponent(Company({ uuid: data.id }), document.querySelector('body > main'))

  # Fetch all posts with dependencies
  #
  require('sync/post_sync_api').fetchAll(data.id).done (json) ->

    Dispatcher.handleServerAction
      type: 'post:fetch-all:done'
      data: [json]

    _.each {
      posts: PostStore
      blocks: BlockStore
      pictures: PictureStore
      paragraphs: ParagraphStore
      visibilities: VisibilityStore
    }, (store, key) ->
      _.each json[key], (item) -> store.add(item.uuid, item)

    PostStore.emitChange()

  # Fetch company with dependencies
  #
  require('sync/company').fetch(data.id).done (json) ->
    Dispatcher.handleServerAction
      type: 'company:fetch:done'
      data: [data.id, json]

    _.each {
      blocks:     BlockStore
      pictures:   PictureStore
      paragraphs: ParagraphStore
      people:     PersonStore
      vacancies:  VacancyStore
      # tags:       TagStore # Updated by dispatcher
    }, (store, key) ->
      _.each json[key], (item) -> store.add(item.uuid, item)

    CompanyStore.add(json.company.uuid, json.company)
    CompanyStore.emitChange()

# Finance
#
@['companies#finance'] = (data) ->
  BurnRate = require('components/company/burn_rate')

  React.renderComponent(
    BurnRate(data.company)
    document.querySelector('body > main')
  )

# Settings
#
@['companies#settings'] = (data) ->
  require('sync/company').fetch(data.id).done (json) ->

    CompanyStore  = require('stores/company')

    Dispatcher.handleServerAction
      type: 'company:fetch:done'
      data: [data.id, json]

    CompanyStore.add(json.company.uuid, json.company)
    CompanyStore.emitChange()

  Settings = require('components/company/settings')
  React.renderComponent(Settings({ uuid: data.id }), document.querySelector('body > main'))

# Access rights
#
@['companies#access_rights'] = (data) ->

  CompanyStore = require('stores/company')
  UserStore = require('stores/user_store')
  RoleStore = require('stores/role_store')
  TokenStore = require('stores/token_store')

  CompanyAccessRights = require('components/company/access_rights')

  # Fetch
  #
  require('sync/company').fetchAccessRights(data.id).done (json) ->

    Dispatcher.handleServerAction
      type: 'company:access_rights:fetch:done'
      data: [data.id, json]

    _.each {
      users:      UserStore
      roles:      RoleStore
      tokens:     TokenStore
    }, (store, key) ->
      _.each json[key], (item) -> store.add(item.uuid, item)

    CompanyStore.add(json.company.uuid, json.company)
    CompanyStore.emitChange()

  # Mount
  #
  React.renderComponent(
    CompanyAccessRights({ uuid: data.id }),
    document.querySelector('[data-react-mount-point="access-rights"]')
  )
