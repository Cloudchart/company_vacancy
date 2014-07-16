@['companies#new'] = @['companies#edit'] = ->
  
  $('input[type="file"]').on 'change', (event) ->
    
    $el = $(@)
    
    data = new FormData
    data.append($el.attr('name'), @files[0])
    
    $.ajax
      url:          $el.data('path')
      type:         'POST'
      data:         data
      dataType:     'script'
      processData:  false
      contentType:  false

    @innerHTML = @innerHTML


# Show company
#
@['companies#show'] = (data) ->
  
  cc.module('react/editor/placeholders').exports  = data.placeholders
  cc.module('countries').exports                  = data.countries
  cc.module('industries').exports                 = data.industries
  
  CompanyComponent  = cc.require('react/company')
  container         = document.querySelector('main')
  
  React.renderComponent(CompanyComponent(data.company), container)


# @['companies#show'] = (data) ->
#   $ ->
#     cc.acts_as_editable_article() if data.can_update_company
#     cc.acts_as_editable_side_nav() if data.can_update_company

#     # Sticky containers (TODO: use cc.ui.sticky())
#     #
#     sticky $('[data-behaviour~=editable-article-blocks], [data-behaviour~=editable-article-nav]'),
#       offset:
#         top: $('body > header').outerHeight()


@['companies#search'] = (data) ->
  @['companies#index'](data)


@['companies#index'] = (data) ->
  $ ->
    cc.companies_section_chevron_toggle()



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






