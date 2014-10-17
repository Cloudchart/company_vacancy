###
  Used in:

  ujs/header_login
###

@cc      ?= {}
@cc.ui   ?= {}


#
#
#

$flash = -> 
  flash = $('#flash')
  if flash.length > 0 then flash else 0


default_options =
  type:           'notice'
  close_button:   true


# Create flash
#

create = (message, options = {}) ->
  flash = $('<div>')
    .attr('id', 'flash')
    .html(message)
    .insertBefore('body > main')
  
  flash.addClass(options.type) if options.type?
  
  if options.close_button == true
    flash.append $('<i>').addClass('fa fa-times close')
  
  flash


#
# Widget
#

widget = (message, options = {}) ->
  widget.hide()
  create(message, $.extend({}, default_options, options))
  
  

#
# Common flash types
#

['notice', 'alert', 'error'].forEach (type) ->
  widget[type] = (message, options = {}) -> widget(message, $.extend(options, { type: type }))


#
# Hide shown flash
#

widget.hide = ->
  return unless $flash()
  $flash().hide().remove()


#
# Flash events
#

$(document).on 'click', '#flash i.close', widget.hide

#
#
#

$.extend @cc.ui,
  flash: widget
