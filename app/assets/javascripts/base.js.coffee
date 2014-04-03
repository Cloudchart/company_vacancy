@cc        ?= {}
cc.utils   ?= {}

#
#
#


prefixes                = "webkit Webkit moz Moz ms Ms o O".split(' ')
document_element_style  = document.documentElement.style

cc.utils.get_style_property_name = (name) ->
  return unless name
  
  return name if typeof document_element_style[name] == 'string'
  
  name            = name.charAt(0).toUpperCase() + name.slice(1)
  valid_prefixes  = prefixes.filter (prefix) -> typeof document_element_style[prefix + name] == 'string'
  
  valid_prefixes[0] + name if valid_prefixes.length > 0

#
#
#

jQuery ->
  #
  # Toggable section
  #
  $('main').on 'click', '.toggleable-link', (event) -> 
    $i = $(this).find('i')

    $(this).parent().next('.toggleable-content').toggle 0, ->
      if $i.hasClass('fa-caret-down')
        $i.removeClass().addClass('fa fa-caret-right')
      else
        $i.removeClass().addClass('fa fa-caret-down')

    event.preventDefault()

  #
  # Scrollable anchor
  #
  $(document).on 'click', 'a[href^="#"][data-scrollable-anchor]', (event) ->
    $anchor = $($(@).attr('href')) ; return if $anchor.length == 0

    event.preventDefault()
    
    $(document.body).animate
      scrollTop: $anchor.offset().top
    , 250
