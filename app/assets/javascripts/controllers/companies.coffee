# Show
# 
@['companies#show'] = (data) ->

  require('sync/company').fetch(data.id).done (json) ->
    CompanyStore = require('stores/company')
    CompanyActions  = require('actions/company')

    _.each {
      blocks:     require('stores/block_store')
      pictures:   require('stores/picture_store')
      paragraphs: require('stores/paragraph_store')
      people:     require('stores/person')
      vacancies:  require('stores/vacancy') 
      roles:      require('stores/roles')
      tokens:     require('stores/token')
      users:      require('stores/users')
    }, (store, key) ->
      _.each json[key], (item) -> store.add(item.uuid, item)

    CompanyStore.add(json.company.uuid, json.company)
    CompanyStore.emitChange()

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
  Settings      = cc.require('react/company/settings')
  TagActions    = require('actions/tag_actions')
  CompanyStore  = require('stores/company_store')

  CompanyStore.add(data.company)
  TagActions.fetch()

  React.renderComponent(
    Settings(_.extend({ people: data.people }, data.company))
    document.querySelector('body > main')
  )

# Access rights
# 
# @cjsx React.DOM
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
    <AccessRights key=data.company.uuid invitable_roles=data.invitable_roles />,
    document.querySelector('[data-react-mount-point="access-rights"]'))


# Search
# 
@['companies#search'] = (data) ->
  @['companies#index'](data)

# Index
# 
@['companies#index'] = (data) ->
  $ ->
    # cc.init_chart_preview(true, 0.4)

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
