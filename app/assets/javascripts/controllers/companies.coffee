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
  
  cc.module('react/editor/placeholders').exports = data.placeholders
  
  CompanyComponent  = cc.require('react/company')
  container         = document.querySelector('main')
  
  React.renderComponent(CompanyComponent(data.company), container)
