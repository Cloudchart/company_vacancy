@cc        ?= {}
cc.utils   ?= {}

prefixes                = "webkit Webkit moz Moz ms Ms o O".split(' ')
document_element_style  = document.documentElement.style

cc.utils.get_style_property_name = (name) ->
  return unless name
  
  return name if typeof document_element_style[name] == 'string'
  
  name            = name.charAt(0).toUpperCase() + name.slice(1)
  valid_prefixes  = prefixes.filter (prefix) -> typeof document_element_style[prefix + name] == 'string'
  
  valid_prefixes[0] + name if valid_prefixes.length > 0

cc.utils.form_data_ajax_call = ($input_selector) ->
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
