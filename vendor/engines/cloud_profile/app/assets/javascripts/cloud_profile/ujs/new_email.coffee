new_selector      = 'section.emails li.new-email a'
cancel_selector   = 'section.emails li.form a.cancel'


@['cloud_profile/emails#create'] = @['cloud_profile/emails#index'] = ->
  
  $ ->
    
    
    $(document).on 'click', new_selector, (event) ->
      event.preventDefault()
      
      $li   = $(@).closest('li')
      
      return if $li.prev().hasClass('form')

      $li.before($('template#new-email-form').html())
      $li.css('opacity', 0)


    $(document).on 'click', cancel_selector, (event) ->
      event.preventDefault()
      
      $li = $(@).closest('li')
      
      $li.next().css('opacity', 1)
      $li.remove()
