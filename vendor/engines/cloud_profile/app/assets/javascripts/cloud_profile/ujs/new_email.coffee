selector = "main.cloud-profile section.emails"

$ ->
  
  $document = $(document)
  
  # Cancel button click
  #
  $document.on 'click', "#{selector} form a.cancel", (event) ->
    event.preventDefault()
    $(@).closest('form').remove()
  
  # Escape button press
  #
  $document.on 'keydown', "#{selector} form input", (event) ->
    $(@).closest('form').remove() if event.keyCode == 27

  # New email button
  #
  $document.on 'click', "#{selector} button.new-email", (event) ->
    $(@).before($('#new-email-form-template').html())
