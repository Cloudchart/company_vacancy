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
  
# Show
#
# @['companies#show_old'] = (data) ->
#   cc.module('react/editor/placeholders').exports  = data.placeholders
#   #cc.module('countries').exports                  = data.countries
#   cc.module('industries').exports                 = data.industries
  
#   PersonStore       = cc.require('cc.stores.PersonStore')
#   VacancyStore      = cc.require('cc.stores.VacancyStore')
#   CompanyStore      = require('stores/company_store')
#   TagStore          = require('stores/tag_store')
#   TagActions        = -> require('actions/tag_actions')
#   CountryStore      = cc.require('cc.stores.CountryStore')

#   CompanyComponent  = cc.require('react/company')
#   container         = document.querySelector('main')
  
#   CompanyStore      = require('stores/company_store')
  
  
#   CompanyStore.add(data.company)
#   PersonStore.load(data.company.people_url)
#   VacancyStore.load(data.company.vacancies_url)
#   TagActions().fetch()
  

#   _.each data.countries, (pair) ->
#     CountryStore.add(new CountryStore({ id: pair[1], name: pair[0] }))
  

#   CountryStore.emitChange()

#   React.renderComponent(CompanyComponent({ key: data.company.uuid }), container)
  

# Search
# 
@['companies#search'] = (data) ->
  @['companies#index'](data)

# Index
# 
@['companies#index'] = (data) ->
  $ ->
    cc.init_chart_preview(true, 0.4)

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
