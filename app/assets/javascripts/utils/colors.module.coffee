Colors = [
  'hsl( 39, 85%, 71%)'
  'hsl(141, 46%, 59%)'
  'hsl(196, 91%, 69%)'
  'hsl( 25, 80%, 67%)'
  'hsl(265, 55%, 76%)'
  'hsl(344, 88%, 76%)'
  'hsl( 84, 75%, 75%)'
  'hsl(229, 75%, 72%)'
  'hsl( 59, 76%, 76%)'
  'hsl(144, 75%, 75%)'
  'hsl(359, 57%, 76%)'
  'hsl(206, 57%, 76%)'
]


# Color Inidex
#
ColorIndex = (value) ->
  value.split('').reduce(((memo, letter) -> memo += letter.charCodeAt(0)), 0) % Colors.length


module.exports =
  colors:     Colors
  colorIndex: ColorIndex
