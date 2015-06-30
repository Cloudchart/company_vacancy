is_iphone = ->
  window.matchMedia('only screen and (min-device-width: 320px) and (max-device-width: 736px)').matches

is_ipad = ->
  window.matchMedia('only screen and (min-device-width: 768px) and (max-device-width: 1024px)').matches

is_portrait = ->
  window.matchMedia('only screen and (orientation: portrait)').matches

is_landscape = ->
  window.matchMedia('only screen and (orientation: landscape)').matches


# Exports
#
module.exports =
  is_iphone:    is_iphone()
  is_ipad:      is_ipad()
  is_portrait:  is_portrait()
  is_landscape: is_landscape()
