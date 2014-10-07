module.exports = (value) ->
  value             = '' unless value

  uppercasedLetters = value.toUpperCase().split('').filter((letter, i) -> letter != ' ' and letter == value[i]).join('')
  initialLetters    = value.split(' ').map((part) -> part.charAt(0)).join('')
  
  (
    if uppercasedLetters.length >= 2 then uppercasedLetters
    else if initialLetters.length >= 2 then initialLetters
    else value
  )[0...2].toUpperCase()
