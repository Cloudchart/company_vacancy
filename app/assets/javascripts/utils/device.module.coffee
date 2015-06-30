is_iphone = ->
  window.matchMedia('only screen and (min-device-width: 320px) and (max-device-width: 736px)').matches


# Exports
#
module.exports =
  is_iphone: is_iphone()
