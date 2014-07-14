##= require module
##= require colors

# Imports
#
tag     = cc.require('react/dom')
colours = cc.require('colours')


# 2 Letters from String
#
lettersFrom = (string) ->
  uppercasedLetters = string.toUpperCase().split('').filter((letter, i) -> letter != ' ' and letter == string[i]).join('')
  initialLetters    = string.split(' ').map((part) -> part.charAt(0)).join('')
  
  (
    if uppercasedLetters.length >= 2 then uppercasedLetters
    else if initialLetters.length >= 2 then initialLetters
    else string
  )[0...2].toUpperCase()


# Checksum
#
checksumFrom = (letters) ->
  letters.split('').reduce(((memo, letter) -> memo += letter.charCodeAt(0)), 0)


# Background Color
#
backgroundColor = (string) ->
  colours[checksumFrom(lettersFrom(string)) % colours.length]


# State
#
calculateState = (string) ->
  letters   = lettersFrom(string)
  checksum  = checksumFrom(letters)
  
  { letters: letters, checksum: checksum }


# Main Component
#
MainComponent = React.createClass


  componentWillReceiveProps: (nextProps) ->
    @setState calculateState(nextProps.string)


  getInitialState: ->
    calculateState(@props.string)


  render: ->
    (tag.figure {
      className: 'letter-avatar'
      style:
        backgroundColor: colours[@state.checksum % colours.length]
    },
      (tag.span {}, @state.letters)
    )


# Exports
#
cc.module('react/shared/letter-avatar').exports                   = MainComponent
cc.module('react/shared/letter-avatar/background-color').exports  = backgroundColor
