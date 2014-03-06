@cc      ?= {}
@cc.ui   ?= {}

$         = jQuery

trigger_selector    = '[data-behaviour~="circular-popup-trigger"]'


current_popup       = null


#
#
#

started = false

widget = ->
  return if started ; started = true
  

#
#
#

$.extend @cc.ui,
  circular_popup: widget

# NB: DELETE!!!
widget()