@cc        ?= {}
@cc.utils  ?= {}

#
# Styles
#

document_element_style  = document.documentElement.style
prefixes                = ['webkit', 'Webkit', 'moz', 'Moz', 'ms', 'Ms', 'o', 'O']

@cc.utils.check_style_property = (property) ->
  return unless property?
  
  return property if typeof document_element_style[property] == 'string'
  
  property          = property.charAt(0).toUpperCase() + property.slice(1)
  filtered_prefixes = prefixes.filter (prefix) -> typeof document_element_style[prefix + property] == 'string'
  
  return filtered_prefixes[0] + property if filtered_prefixes.length > 0


#
#
#

jQuery ->
    # toggable section
    $('main').on 'click', '.toggleable-link', (event) -> 
        $i = $(this).find('i')

        $(this).parent().next('.toggleable-content').toggle 0, ->
            if $i.hasClass('fa-caret-down')
                $i.removeClass().addClass('fa fa-caret-right')
            else
                $i.removeClass().addClass('fa fa-caret-down')

        event.preventDefault()

