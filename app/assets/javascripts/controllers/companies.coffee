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
