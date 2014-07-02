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

  BlocksSidebar = cc.react.editor.BlocksSidebarComponent({
    blocks:   data.blocks
  })

  React.renderComponent(cc.react.company.MainComponent({
    url:            data.url
    company:        data.company
    company_blocks: data.company_blocks
    sections:       data.sections
  },
    BlocksSidebar
  ), document.querySelector('main'))
