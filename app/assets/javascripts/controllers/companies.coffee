@['companies#show'] = (data) ->
  CompanyApp      = require('components/company_app')
  CompanyStore    = require('stores/company')
  BlockStore      = require('stores/block_store')
  PictureStore    = require('stores/picture_store')
  ParagraphStore  = require('stores/paragraph_store')
  VacancyStore    = require('stores/vacancy')

  CompanyStore.add(data.company.uuid, data.company)
  
  _.each data.blocks,     (block)     -> BlockStore.add(block.uuid, block)
  _.each data.pictures,   (picture)   -> PictureStore.add(picture.uuid, picture)
  _.each data.paragraphs, (paragraph) -> ParagraphStore.add(paragraph.uuid, paragraph)
  _.each data.vacancies,  (vacancy)   -> VacancyStore.add(vacancy.uuid, vacancy)
  
  React.renderComponent(
    CompanyApp({ key: data.company.uuid })
    document.querySelector('body > main')
  )

# Show
#
@['companies#show'] = (data) ->
  cc.module('react/editor/placeholders').exports  = data.placeholders
  #cc.module('countries').exports                  = data.countries
  cc.module('industries').exports                 = data.industries
  
  PersonStore       = cc.require('cc.stores.PersonStore')
  VacancyStore      = cc.require('cc.stores.VacancyStore')
  CompanyStore      = require('stores/company_store')
  TagStore          = require('stores/tag_store')
  TagActions        = -> require('actions/tag_actions')
  CountryStore      = cc.require('cc.stores.CountryStore')

  CompanyComponent  = cc.require('react/company')
  container         = document.querySelector('main')
  
  CompanyStore      = require('stores/company_store')
  
  
  CompanyStore.add(data.company)
  PersonStore.load(data.company.people_url)
  VacancyStore.load(data.company.vacancies_url)
  TagActions().fetch()
  

  _.each data.countries, (pair) ->
    CountryStore.add(new CountryStore({ id: pair[1], name: pair[0] }))
  

  CountryStore.emitChange()

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
