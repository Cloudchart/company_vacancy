###
  Used in:
  components/company/preview/item
###

# Colors
#
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


# Vacancy Color
#
VacancyColor = 'hsl(1, 76%, 54%)'


# Color Inidex
#
ColorIndex = (value) ->
  value.split('').reduce(((memo, letter) -> memo += letter.charCodeAt(0)), 0) % Colors.length

getColorByLetters = (letters) ->
  Colors[ColorIndex(letters)]

# Exports
#
cc.module('cc.utils.Colors').exports          = Colors
cc.module('cc.utils.Colors.Index').exports    = ColorIndex
cc.module('cc.utils.Colors.Vacancy').exports  = VacancyColor
cc.module('cc.utils.Colors.getColorByLetters').exports = getColorByLetters
