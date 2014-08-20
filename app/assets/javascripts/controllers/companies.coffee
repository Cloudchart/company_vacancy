# Deprecated
# 
# @['companies#new'] = @['companies#edit'] = ->
  
#   $('input[type="file"]').on 'change', (event) ->
    
#     $el = $(@)
    
#     data = new FormData
#     data.append($el.attr('name'), @files[0])
    
#     $.ajax
#       url:          $el.data('path')
#       type:         'POST'
#       data:         data
#       dataType:     'script'
#       processData:  false
#       contentType:  false

#     @innerHTML = @innerHTML


# Show
#
@['companies#show'] = (data) ->
  cc.module('react/editor/placeholders').exports  = data.placeholders
  #cc.module('countries').exports                  = data.countries
  cc.module('industries').exports                 = data.industries
  
  PersonStore       = cc.require('cc.stores.PersonStore')
  VacancyStore      = cc.require('cc.stores.VacancyStore')
  CountryStore      = cc.require('cc.stores.CountryStore')
  
  CompanyComponent  = cc.require('react/company')
  container         = document.querySelector('main')
  
  React.renderComponent(CompanyComponent(data.company), container)

  PersonStore.load(data.company.people_url)
  VacancyStore.load(data.company.vacancies_url)
  
  _.each data.countries, (pair) ->
    CountryStore.add(new CountryStore({ id: pair[1], name: pair[0] }))
  
  CountryStore.emitChange()
  
  


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
