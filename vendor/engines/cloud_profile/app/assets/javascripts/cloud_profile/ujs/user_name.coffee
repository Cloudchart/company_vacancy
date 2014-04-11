$ ->
  
  $form = $('main.cloud-profile section.profile-name form')
  

  # prevent form from submit on enter
  #
  $form.on 'submit', (event) -> event.preventDefault()
  

  # update user name
  #
  $form.on 'blur', 'input', (event) ->
    
    $.ajax
      url:          $form.attr('action')
      type:         'put'
      data:         $form.serializeArray()
