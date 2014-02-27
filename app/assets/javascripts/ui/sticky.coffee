@cc      ?= {}
@cc.ui   ?= {}

$         = jQuery

#
#
#

widget = (element, options = {}) ->
  $element  = $(element) ; return if $element.length == 0
  $parent   = $element.parent()
  $document = $(document)
  $window   = $(window)
  
  anchor    =
    top:    $element.offset().top
  
  sticky    = false
  
  top       = anchor.top
  
  
  unless (/^(abs|rel)/).exec($element.css('position'))
    $element.css('position', 'relative')
  
  
  # Update position
  #
  
  update_position = ->
    document_height     = $document.height()
    window_scroll_top   = $window.scrollTop()
    position            = $element.offset()
    
    if anchor.top - window_scroll_top < 0
      top = window_scroll_top
      return
    
    if position.top > anchor.top
      top = anchor.top
      return


  animate = ->
    $element.offset
      top: top
    
    window.requestAnimationFrame(animate)
  
  #
  #
  #
  
  $window.on 'scroll', update_position
  
  #animate()
  

#
#
#

$.extend @cc.ui,
  sticky: widget
