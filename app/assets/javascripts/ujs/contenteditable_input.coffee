$ ->
  
  selector  = '[contenteditable][data-behaviour~="input"]'
  
  $document = $(document)
  
  # Prevent line breaks and tags
  #
  $document.on 'input', selector, -> $el = $(@) ; $el.html($el.text())

  