selector = 'label.error input[data-behaviour~="toggle-error"]'

$ ->
  
  $(document).on 'keypress', selector, (event) ->
    $(@).closest('label.error').removeClass('error')
