###
  Used in:

  cloud_blueprint/react/spinner
  cloud_blueprint/nodes/edit
  cloud_blueprint/nodes/new
  cloud_blueprint/people/create
  cloud_blueprint/people/destroy
  cloud_blueprint/people/update
  cloud_blueprint/vacancies/create
  cloud_blueprint/vacancies/destroy
  cloud_blueprint/vacancies/update
###

@cc      ?= {}
@cc.ui   ?= {}

$         = jQuery

#
#
#

modals      = []

callbacks   =
  before_show: []
  after_show: []
  before_close: []
  after_close: []

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

widget = (content, options = {}) ->
  ensure()
  
  _.each callbacks, (memo, key) -> memo.push if _.isFunction(options[key]) then options[key] else $.noop
  
  callbacks.before_show.pop()()

  $overlay.toggleClass('locked', options.locked == true)
  $container.html(content)
  $overlay.show()

  callbacks.after_show.pop()($container.get(0))
  
  

widget.close = ->
  ensure()

  callbacks.before_close.pop()($container.get(0))

  $container.html('')
  $overlay.hide()

  callbacks.after_close.pop()()

#
#
#


$ ->
  
  $document = $(document)
  $window   = $(window)
  
  $document.on 'click', 'body > .modal-overlay:not(.locked)', (event) -> widget.close()
  $document.on 'click', 'body > .modal-container', (event) -> event.stopPropagation()


#
#
#

$.extend @cc.ui,
  modal: widget
