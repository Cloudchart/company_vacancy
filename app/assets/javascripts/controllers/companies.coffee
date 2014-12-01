# @cjsx React.DOM

# Show
# 
@['companies#show'] = (data) ->

  CompanyStore = require('stores/company')
  PostStore = require('stores/post_store')
  BlockStore = require('stores/block_store')
  PictureStore = require('stores/picture_store')
  ParagraphStore = require('stores/paragraph_store')
  PersonStore = require('stores/person')
  VacancyStore = require('stores/vacancy') 
  RolesStore = require('stores/roles')
  TokenStore = require('stores/token')
  UsersStore = require('stores/users')
  TagStore = require('stores/tag_store')
  
  # Fetch company
  # 
  require('sync/company').fetch(data.id).done (json) ->
    _.each {
      blocks:     BlockStore
      pictures:   PictureStore
      paragraphs: ParagraphStore
      people:     PersonStore
      vacancies:  VacancyStore
      roles:      RolesStore
      tokens:     TokenStore
      users:      UsersStore
      tags:       TagStore
    }, (store, key) ->
      _.each json[key], (item) -> store.add(item.uuid, item)

    CompanyStore.add(json.company.uuid, json.company)
    CompanyStore.emitChange()

  # Fetch all posts
  # 
  require('sync/post_sync_api').fetchAll(data.id).done (json) ->
    _.each json, (object) ->

      PostStore.add(object.post.uuid, object.post)

      _.each {
        blocks: BlockStore
        pictures: PictureStore
        paragraphs: ParagraphStore
      }, (store, key) ->
        _.each object[key], (item) -> store.add(item.uuid, item)

    PostStore.emitChange()

  # Mount company
  # 
  Company = require('components/company_app')
  React.renderComponent(Company({ id: data.id }), document.querySelector('body > main'))

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

    CompanyStore.add(json.company.uuid, json.company)
    CompanyStore.emitChange()

  Settings = require('components/company/settings')
  React.renderComponent(Settings({ uuid: data.id }), document.querySelector('body > main'))

# Access rights
# 
@['companies#access_rights'] = (data) ->
  
  CompanyStore  = require('stores/company')
  TokenStore    = require('stores/token')
  UsersStore    = require('stores/users')
  RolesStore    = require('stores/roles')
  
  CompanyActions  = require('actions/company')

  promises = [
    CompanyActions.fetchAccessRights(data.company.uuid)
    CompanyActions.fetchInviteTokens(data.company.uuid)
  ]

  CompanyStore.add(data.company.uuid, data.company)
  AccessRights = require('components/company/access_rights')

  React.renderComponent(
    <AccessRights key=data.company.uuid
                  emails=data.emails
                  invitable_roles=data.invitable_roles />,
    document.querySelector('[data-react-mount-point="access-rights"]'))

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
