###
  Used in:

  shared/editable_articles
###

@cc ?= {}

block_image_input_selector = ".editable-article-wrapper article section .identity-block.block_image input[type=file]"

widget = ->
  
  $('main').on 'change', block_image_input_selector, ->
    cc.utils.form_data_file_ajax_update($(@))
  
widget()
