# Show
#
@['companies#show'] = (data) ->
  cc.module('react/editor/placeholders').exports  = data.placeholders
  
  PersonStore       = cc.require('cc.stores.PersonStore')
  VacancyStore      = cc.require('cc.stores.VacancyStore')
  CompanyStore      = require('stores/company_store')
  TagStore          = require('stores/tag_store')
  TagActions        = -> require('actions/tag_actions')
  CompanyComponent  = cc.require('react/company')
  container         = document.querySelector('main')
  
  CompanyStore.add(data.company)
  PersonStore.load(data.company.people_url)
  VacancyStore.load(data.company.vacancies_url)
  TagActions().fetch()
  
  React.renderComponent(CompanyComponent({ key: data.company.uuid }), container)

# Search
# 
@['companies#search'] = (data) ->
  @['companies#index'](data)

# Index
# 
@['companies#index'] = (data) ->
  $ ->
    # cc.companies_section_chevron_toggle()
    cc.init_chart_preview(true, 0.4)


jQuery ->
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
