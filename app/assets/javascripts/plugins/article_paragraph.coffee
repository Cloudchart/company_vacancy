@cc          ?= {}
@cc.plugins  ?= {}

$             = jQuery


selector                = 'article section .paragraph form [contenteditable]'
block_children_selector = '>div, >p'

block_element_re  = /^div$|^p$/i
br_element_re     = /^br$/i
strip_re          = /^\s+|\s+$/g


strip     = (string) -> string.replace(strip_re, '')


#
#
#

started = false

widget = ->
  
  return if started ; started = true
  
  
  # On focus
  #
  on_focus = ->
    document.execCommand('DefaultParagraphSeparator', false, 'div')


  # On input
  #
  on_input = ->
    @normalize()
    @innerHTML = '' unless strip(@innerText).length
  
  
  # On blur
  #
  on_blur = ->
    @normalize()


    # Unwrap all spans' content
    #
    Array.prototype.slice.call(@querySelectorAll('span')).forEach (node) ->
      node.insertAdjacentHTML('beforebegin', node.innerHTML)
      node.parentNode.removeChild(node)

    
    # Unwrap all p's content
    #
    Array.prototype.slice.call(@children).forEach (node) ->
      return unless node.nodeName.match(block_element_re)
      
      # Insert line break if following text node
      #
      if node.previousSibling and node.previousSibling.nodeType == 3
        node.parentNode.insertBefore(document.createElement('br'), node)

      # Unwrap leading <br />
      #
      child_node = node.childNodes[0]
      
      if child_node and child_node.nodeName and child_node.nodeName.match(br_element_re)
        node.parentNode.insertBefore(child_node, node)
      
      # Remove trailing <br />
      #
      child_node = node.childNodes[node.childNodes.length - 1]
      
      if child_node and child_node.nodeName and child_node.nodeName.match(br_element_re)
        node.removeChild(child_node)
      
      # Unwrap content
      #
      if node.childNodes.length > 0
        node.insertAdjacentHTML('beforebegin', node.innerHTML)

      node.parentNode.removeChild(node)
      
    
    $(@).closest('form').find(@dataset['target']).val(@innerHTML)
    $(@).closest('form').submit()
  

  #
  # Event observer
  #
  
  $(document).on 'focus', selector, on_focus

  $(document).on 'input', selector, on_input

  $(document).on 'blur', selector, on_blur
  

#
#
#

@cc.plugins.article_paragraph = widget
