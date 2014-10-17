###
  Used in:

  block_identities/block_images
  shared/editable_side_nav
###

@cc        ?= {}
cc.utils   ?= {}

prefixes                = "webkit Webkit moz Moz ms Ms o O".split(' ')
document_element_style  = document.documentElement.style

cc.utils.form_data_file_ajax_update = ($input_selector) ->
  $form_selector = $input_selector.closest('form')
  formData = new FormData()
  formData.append $input_selector.attr('name'), $input_selector[0].files[0]

  $.ajax
    url: $form_selector.attr('action')
    data: formData
    dataType: 'script'
    type: 'PUT'
    cache: false
    contentType: false
    processData: false
