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
  
  companyComponent  = cc.react.company.Main(data.company)
  container         = document.querySelector('main')
  
  React.renderComponent(companyComponent, container)
