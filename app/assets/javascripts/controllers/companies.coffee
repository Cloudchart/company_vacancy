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
  TagStore        = require('stores/tag_store')
  VisibilityStore = require('stores/visibility_store')
  
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
      roles:      RoleStore
      tokens:     TokenStore
      users:      UserStore
      # tags:       TagStore # Updated by dispatcher
    }, (store, key) ->
      _.each json[key], (item) -> store.add(item.uuid, item)

    CompanyStore.add(json.company.uuid, json.company)
    CompanyStore.emitChange()

  # Fetch all posts with dependencies
  # 
  require('sync/post_sync_api').fetchAll(data.id).done (json) ->
    _.each {
      posts: PostStore
      blocks: BlockStore
      pictures: PictureStore
      paragraphs: ParagraphStore
      visibilities: VisibilityStore
    }, (store, key) ->
      _.each json[key], (item) -> store.add(item.uuid, item)

    PostStore.emitChange()

  # Mount company
  # 
  Company = require('components/company_app')
  React.renderComponent(Company({ uuid: data.id }), document.querySelector('body > main'))

# Finance
# 
@['companies#finance'] = (data) ->
  BurnRate = cc.require('react/company/burn_rate')

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
      type: 'company:fetch:access_rights:done'
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

# Search
# 
@['companies#search'] = (data) ->
  @['companies#index'](data)

# Index
# 
@['companies#index'] = (data) ->
  $ ->
    # comanies search
    #
    $('header').on 'input propertychange', '.search input', ->
      perform_search($(@))

    search_timeout = null

    search = ($element) ->
      value = $element.val().replace(/^\s+|\s+$/g, '') 
      return if value.length < 3 and value.length > 0
      $element.closest('form').submit()

    perform_search = ($element) ->
      clearTimeout(search_timeout)
      search_timeout = setTimeout((-> search($element)), 700)
