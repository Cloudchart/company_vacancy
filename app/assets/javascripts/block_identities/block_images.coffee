@cc ?= {}

block_image_input_selector = "article section .identity-block.block_image input[type=file]"

widget = ->
  
  $document = $(document)
  
  $document.on 'change', block_image_input_selector, ->
    $(@).closest('form').submit()
  

widget()