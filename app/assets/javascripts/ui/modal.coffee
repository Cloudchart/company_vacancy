@cc      ?= {}
@cc.ui   ?= {}

$         = jQuery

#
#
#

modals = []

$overlay    = null
$container  = null

ensure = ->
  $overlay    ||= $('<div>')
    .addClass('modal-overlay')
    .appendTo('body')
  
  $container  ||= $('<div>')
    .addClass('modal-container')
    .appendTo($overlay)

#
#
#

widget = (content) ->
  ensure()
  
  $container.html(content)
  
  $overlay.show()
  
  

widget.close = ->
  ensure()
  $container.html('')
  $overlay.hide()

#
#
#


$ ->
  
  $document = $(document)
  $window   = $(window)
  
  $document.on 'click', '.modal-overlay', (event) -> widget.close()
  $document.on 'click', '.modal-container', (event) -> event.stopPropagation()


#
#
#

$.extend @cc.ui,
  modal: widget
